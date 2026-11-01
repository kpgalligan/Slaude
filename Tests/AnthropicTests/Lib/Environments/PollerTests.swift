// Port of tests/lib/environments/test_poller.py and test_poller_method.py (the async `aiter_work` tests; the sync
// `iter_work` ones are their twins, ported once).
//
// Upstream's fakes stand in for the work resource; here `EnvFakeWork` implements `EnvironmentWorkAPI`. Python
// throws into the generator (`athrow`) to simulate the loop body raising; Swift runs the body through
// `forEach(_:)`, which stops the item when the body throws.

import Foundation
import Testing
@testable import Anthropic

/// A sentinel that ends a poll loop once its script runs out (`_StopTest`): not an API or transport error, so the
/// poller propagates it.
struct EnvStopTest: Error {}

struct EnvBugError: Error, Equatable {
    let message: String
}

func envAPIStatusError(_ code: Int, body: JSONValue? = nil) -> APIStatusError {
    let request = HTTPRequest(method: "POST", url: URL(string: "https://api.example/poll")!)
    let data = body.flatMap { try? JSONValue.serialize($0) } ?? Data("{}".utf8)
    return APIStatusError("boom", response: HTTPResponse(statusCode: code, body: data, request: request), body: body)
}

func envWork(_ id: String = "work_1", type: String = "session", sessionID: String = "s_1", secret: String? = nil,
             environmentID: String = "env_1") -> BetaSelfHostedWork
{
    BetaSelfHostedWork(
        id: id, createdAt: "2026-01-01T00:00:00Z", data: BetaSessionWorkData(id: sessionID, type: type), environmentID: environmentID,
        metadata: [:], secret: secret, state: BetaSelfHostedWork.State(rawValue: "active"))
}

/// One scripted poll result: an item, an empty poll, an error, or a step that runs first (moving a fake clock).
enum EnvPollStep: Sendable {
    case item(BetaSelfHostedWork)
    case empty
    case error(any Error)
    case run(@Sendable () -> Void)
}

struct EnvCall: Sendable, Equatable {
    var workID: String
    var environmentID: String
    var force: Bool?
    var extraHeaders: Headers?
}

/// The work resource fake (`FakeAsyncWork`): `poll` consumes its script, `ack` / `stop` record their calls.
final class EnvFakeWork: EnvironmentWorkAPI, @unchecked Sendable {
    private let lock = NSLock()
    private var script: [EnvPollStep]
    private(set) var pollCalls: [(environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String, extraHeaders: Headers?)] = []
    private(set) var ackCalls: [EnvCall] = []
    private(set) var stopCalls: [EnvCall] = []
    var ackError: (any Error)?
    var stopError: (any Error)?

    init(_ script: [EnvPollStep]) { self.script = script }

    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String,
              extraHeaders: Headers?) async throws -> BetaSelfHostedWork?
    {
        let step: EnvPollStep? = lock.withLock {
            pollCalls.append((environmentID, blockMs, reclaimOlderThanMs, workerID, extraHeaders))
            return script.isEmpty ? nil : script.removeFirst()
        }
        switch step {
        case nil: throw EnvStopTest()
        case .item(let w)?: return w
        case .empty?: return nil
        case .error(let e)?: throw e
        case .run(let f)?:
            f()
            return nil
        }
    }

    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws {
        lock.withLock { ackCalls.append(EnvCall(workID: workID, environmentID: environmentID, extraHeaders: extraHeaders)) }
        if let ackError { throw ackError }
    }

    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws {
        lock.withLock { stopCalls.append(EnvCall(workID: workID, environmentID: environmentID, force: force, extraHeaders: extraHeaders)) }
        if let stopError { throw stopError }
    }

    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String,
                   extraHeaders: Headers?) async throws -> BetaSelfHostedWorkHeartbeatResponse
    {
        BetaSelfHostedWorkHeartbeatResponse(lastHeartbeat: "hb", leaseExtended: true, state: .active, ttlSeconds: 60)
    }
}

/// A settable monotonic clock (`_FakeClock`).
final class EnvFakeClock: @unchecked Sendable {
    private let lock = NSLock()
    private var _now = 0.0
    var now: Double {
        get { lock.withLock { _now } }
        set { lock.withLock { _now = newValue } }
    }
    func advance(_ seconds: Double) { now += seconds }
}

/// A poller over `work` that never sleeps.
func envPoller(_ work: EnvFakeWork, drain: Bool = false, autoStop: Bool = true, blockMs: Int? = POLL_BLOCK_MS,
               reclaimOlderThanMs: Int? = nil, extraHeaders: Headers? = nil, clock: EnvFakeClock? = nil) -> EnvironmentWorkPoller
{
    var hooks = EnvironmentPollerHooks()
    hooks.sleep = { _ in }
    if let clock { hooks.now = { clock.now } }
    return EnvironmentWorkPoller(work: work, environmentID: "env_1", workerID: nil, blockMs: blockMs,
                                 reclaimOlderThanMs: reclaimOlderThanMs, drain: drain, autoStop: autoStop, extraHeaders: extraHeaders,
                                 hooks: hooks)
}

@Suite struct EnvRetryHelpersTests {
    @Test(arguments: [(1, 2.0), (2, 4.0), (100, 60.0)])
    func backoff(attempt: Int, want: Double) {
        #expect(HelperRetry.backoff(attempt: attempt, cap: POLL_BACKOFF_CAP) == want)
    }

    @Test func jitterWithinBounds() {
        for _ in 0..<100 {
            let v = HelperRetry.jitter(1, 3)
            #expect(v >= 1 && v < 3)
        }
    }

    @Test(arguments: [(400, true), (401, true), (403, true), (404, true), (408, false), (409, false), (412, true), (422, true),
                      (429, false), (500, false)])
    func isFatalStatusError(status: Int, fatal: Bool) {
        #expect(HelperRetry.isFatalStatusError(envAPIStatusError(status)) == fatal)
    }

    @Test func isFatalStatusErrorIgnoresNonAPIErrors() {
        #expect(!HelperRetry.isFatalStatusError(EnvBugError(message: "bug")))
    }
}

@Suite struct EnvPollerTests {
    @Test func yieldsAcksAndStopsOneItem() async throws {
        let fake = EnvFakeWork([.item(envWork())])
        let poller = envPoller(fake)

        let item = try #require(try await poller.next())
        #expect(item.id == "work_1")
        #expect(fake.ackCalls.map(\.workID) == ["work_1"])
        #expect(fake.stopCalls.isEmpty, "stop should not be called until body returns")

        await #expect(throws: EnvStopTest.self) { try await poller.next() }
        #expect(fake.stopCalls.map(\.workID) == ["work_1"])
        #expect(fake.stopCalls[0].force == nil)
    }

    @Test func callsStopWhenBodyRaises() async throws {
        let fake = EnvFakeWork([.item(envWork("work_boom"))])
        let poller = envPoller(fake)

        await #expect(throws: EnvBugError.self) {
            try await poller.forEach { _ in throw EnvBugError(message: "body failed") }
        }
        #expect(fake.stopCalls.map(\.workID) == ["work_boom"])
    }

    @Test(arguments: [500, 409])
    func backsOffOnTransientError(status: Int) async throws {
        let fake = EnvFakeWork([.error(envAPIStatusError(status)), .item(envWork("work_2"))])
        let item = try await envPoller(fake).next()
        #expect(item?.id == "work_2")
        #expect(fake.pollCalls.count == 2)
    }

    @Test func raisesOnPermanent4xx() async throws {
        let fake = EnvFakeWork([.error(envAPIStatusError(401))])
        await #expect(throws: APIStatusError.self) { try await envPoller(fake).next() }
    }

    @Test func stopConflictIsSilent() async throws {
        let fake = EnvFakeWork([.item(envWork("work_done"))])
        fake.stopError = envAPIStatusError(409)
        let poller = envPoller(fake)

        let (_, capture) = try await ToolDiagnostics.capture {
            _ = try await poller.next()
            await #expect(throws: EnvStopTest.self) { try await poller.next() }
        }
        #expect(fake.pollCalls.count == 2)
        #expect(!capture.records.contains { $0.message.contains("stop failed") })
    }

    @Test func backsOffOnTransportError() async throws {
        let fake = EnvFakeWork([.error(URLError(.cannotConnectToHost)), .item(envWork("work_2"))])
        let item = try await envPoller(fake).next()
        #expect(item?.id == "work_2")
        #expect(fake.pollCalls.count == 2)
    }

    @Test func propagatesNonAPIErrorInsteadOfRetrying() async throws {
        let fake = EnvFakeWork([.error(EnvBugError(message: "bug")), .item(envWork("work_2"))])
        await #expect(throws: EnvBugError.self) { try await envPoller(fake).next() }
        #expect(fake.pollCalls.count == 1)
    }

    @Test func propagatesNonAPIErrorFromAck() async throws {
        let fake = EnvFakeWork([.item(envWork("work_bad"))])
        fake.ackError = EnvBugError(message: "ack bug")
        await #expect(throws: EnvBugError(message: "ack bug")) { try await envPoller(fake).next() }
        #expect(fake.stopCalls.isEmpty)
    }

    @Test func forceStopsOnPermanentAckFailure() async throws {
        let fake = EnvFakeWork([.item(envWork("work_bad"))])
        fake.ackError = envAPIStatusError(403)
        await #expect(throws: EnvStopTest.self) { try await envPoller(fake).next() }
        #expect(fake.stopCalls.map(\.workID) == ["work_bad"])
        #expect(fake.stopCalls[0].force == true)
    }

    @Test func drainReturnsOnEmptyQueue() async throws {
        let fake = EnvFakeWork([.item(envWork("work_a")), .item(envWork("work_b")), .empty])
        var ids: [String] = []
        for try await item in envPoller(fake, drain: true) { ids.append(item.id) }
        #expect(ids == ["work_a", "work_b"])
        #expect(fake.pollCalls.count == 3)
    }

    @Test func drainReturnsImmediatelyWhenQueueEmpty() async throws {
        let fake = EnvFakeWork([.empty])
        var ids: [String] = []
        for try await item in envPoller(fake, drain: true) { ids.append(item.id) }
        #expect(ids.isEmpty)
        #expect(fake.pollCalls.count == 1)
    }

    @Test func autoStopFalseNeverStops() async throws {
        let fake = EnvFakeWork([.item(envWork("work_a")), .item(envWork("work_b")), .empty])
        var ids: [String] = []
        for try await item in envPoller(fake, drain: true, autoStop: false) { ids.append(item.id) }
        #expect(ids == ["work_a", "work_b"])
        #expect(fake.ackCalls.map(\.workID) == ["work_a", "work_b"], "every item should still be ack'd")
        #expect(fake.stopCalls.isEmpty)
        #expect(fake.pollCalls.count == 3)
    }

    @Test func autoStopFalseDoesNotStopOnBodyRaise() async throws {
        let fake = EnvFakeWork([.item(envWork("work_boom"))])
        await #expect(throws: EnvBugError.self) {
            try await envPoller(fake, autoStop: false).forEach { _ in throw EnvBugError(message: "body failed") }
        }
        #expect(fake.stopCalls.isEmpty)
    }

    @Test func forwardsReclaimOlderThanMs() async throws {
        let fake = EnvFakeWork([.empty])
        for try await _ in envPoller(fake, drain: true, reclaimOlderThanMs: 2000) {}
        #expect(fake.pollCalls[0].reclaimOlderThanMs == 2000)
        #expect(fake.pollCalls[0].blockMs == 999)
    }

    @Test func blockMsNilOmitsParam() async throws {
        let fake = EnvFakeWork([.empty])
        for try await _ in envPoller(fake, drain: true, blockMs: nil) {}
        #expect(fake.pollCalls[0].blockMs == nil)
    }

    @Test func logsIdlePolling() async throws {
        let clock = EnvFakeClock()
        // Three empty polls, a fourth 301s later, a fifth, one claim, then one more empty poll before the script
        // runs out.
        let fake = EnvFakeWork([.empty, .empty, .empty, .run { clock.advance(301) }, .empty, .item(envWork("work_a")), .empty])
        let poller = envPoller(fake, autoStop: false, clock: clock)
        let (_, capture) = try await ToolDiagnostics.capture {
            await #expect(throws: EnvStopTest.self) {
                for try await _ in poller {}
            }
        }
        let records = capture.records.filter { $0.logger == "anthropic.lib.environments._poller" && !$0.message.hasPrefix("poller starting") }
        #expect(records.filter { $0.level == .info }.map(\.message) == [
            "idle; polling environment_id=env_1 for work",
            "still polling environment_id=env_1; idle for 301s",
            "claimed work work_id=work_a work_type=session",
            "idle; polling environment_id=env_1 for work",
        ])
        #expect(records.filter { $0.level == .debug }.count == 3)
    }

    @Test func threadsExtraHeadersIntoPollAckStop() async throws {
        let extra: Headers = ["x-trace-id": "trace-123"]
        let fake = EnvFakeWork([.item(envWork("work_h"))])
        let poller = envPoller(fake, extraHeaders: extra)

        let item = try await poller.next()
        #expect(item?.id == "work_h")
        #expect(fake.pollCalls[0].extraHeaders == extra)
        #expect(fake.ackCalls[0].extraHeaders == extra)

        await #expect(throws: EnvStopTest.self) { try await poller.next() }
        #expect(fake.stopCalls[0].extraHeaders == extra)
    }

    @Test func threadsExtraHeadersIntoForceStop() async throws {
        let extra: Headers = ["x-trace-id": "trace-123"]
        let fake = EnvFakeWork([.item(envWork("work_bad"))])
        fake.ackError = envAPIStatusError(403)
        await #expect(throws: EnvStopTest.self) { try await envPoller(fake, extraHeaders: extra).next() }
        #expect(fake.stopCalls[0].workID == "work_bad")
        #expect(fake.stopCalls[0].force == true)
        #expect(fake.stopCalls[0].extraHeaders == extra)
    }

    @Test func closeStopsTheItemHandedOut() async throws {
        let fake = EnvFakeWork([.item(envWork("work_a"))])
        let poller = envPoller(fake)
        _ = try await poller.next()
        await poller.close()
        #expect(fake.stopCalls.map(\.workID) == ["work_a"])
        #expect(try await poller.next() == nil)
    }
}

/// The `poller(...)` method on the work resource, over HTTP: the scoped client, the empty poll, the params.
@Suite struct EnvPollerMethodTests {
    @Test func pollerAuthenticatesWithTheEnvironmentKeyAndTagsItsRequests() async throws {
        let requests = ToolsBox<[HTTPRequest]>([])
        let workJSON: JSONValue = [
            "id": "work_1", "type": "work", "created_at": "2026-01-01T00:00:00Z", "environment_id": "env_1", "metadata": [:],
            "state": "active", "data": ["id": "s_1", "type": "session"],
        ]
        let polls = ToolsBox(0)
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { request in
            requests.mutate { $0.append(request) }
            if request.url.path.hasSuffix("/work/poll") {
                polls.mutate { $0 += 1 }
                return .json(polls.value == 1 ? workJSON : .null, for: request)
            }
            return .json(workJSON, for: request)
        }, environment: [:])

        let poller = try client.beta.environments.work.poller(environmentID: "env_1", environmentKey: "env-key", workerID: "w-1",
                                                              blockMs: nil, reclaimOlderThanMs: 2000, drain: true,
                                                              extraHeaders: ["x-trace-id": "abc"])
        var ids: [String] = []
        for try await item in poller { ids.append(item.id) }
        #expect(ids == ["work_1"])
        let sent = requests.value
        #expect(sent.map { "\($0.method) \($0.url.path)" } == [
            "GET /v1/environments/env_1/work/poll", "POST /v1/environments/env_1/work/work_1/ack",
            "POST /v1/environments/env_1/work/work_1/stop", "GET /v1/environments/env_1/work/poll",
        ])
        for request in sent {
            #expect(request.headers["authorization"] == "Bearer env-key")
            #expect(request.headers["x-api-key"] == nil)
            #expect(request.headers["x-stainless-helper"] == "environments-work-poller")
            #expect(request.headers["x-trace-id"] == "abc")
        }
        let query = URLComponents(url: sent[0].url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(query.first { $0.name == "reclaim_older_than_ms" }?.value == "2000")
        #expect(!query.contains { $0.name == "block_ms" })
        #expect(sent[0].headers["anthropic-worker-id"] == "w-1")
    }

    @Test func defaultWorkerIDIsTheHostnameWithAUniqueSuffix() {
        let a = defaultWorkerID(), b = defaultWorkerID()
        #expect(a != b)
        #expect(a.hasPrefix(localHostName() + "-"))
        #expect(a.count == localHostName().count + 13)
    }
}
