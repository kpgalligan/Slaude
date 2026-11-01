// Port of `anthropic/lib/environments/_poller.py` (`aiter_work`, `POLL_BLOCK_MS`) and the hand-written
// `AsyncWork.poller(...)` of `resources/beta/environments/work.py`: the control-plane poller of a self-hosted
// environment.

import Foundation

/// The API caps `block_ms` at 999; empty polls are spread out with client-side jitter.
public let POLL_BLOCK_MS = 999
let POLL_BACKOFF_CAP: Double = 60
let IDLE_REPORT_INTERVAL: Double = 300

let pollerLog = ToolLogger(name: "anthropic.lib.environments._poller")

/// The work-queue calls the poller and the worker make (`poll`, `ack`, `stop`, `heartbeat` of
/// `client.beta.environments.work`). `client.beta.environments.work` provides them; a fake can stand in.
public protocol EnvironmentWorkAPI: Sendable {
    /// Claim the next work item, or `nil` when the queue has none. A `nil` `blockMs` omits the param.
    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String,
              extraHeaders: Headers?) async throws -> BetaSelfHostedWork?
    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws
    /// Stop a work item; a `nil` `force` omits the param.
    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws
    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String,
                   extraHeaders: Headers?) async throws -> BetaSelfHostedWorkHeartbeatResponse
}

/// `EnvironmentWorkAPI` over the generated `client.beta.environments.work` resource.
struct ResourceEnvironmentWork: EnvironmentWorkAPI {
    let resource: BetaEnvironmentsWorkResource

    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String,
              extraHeaders: Headers?) async throws -> BetaSelfHostedWork?
    {
        let block: Int?? = blockMs.map { .some($0) } ?? .none
        let reclaim: Int?? = reclaimOlderThanMs.map { .some($0) } ?? .none
        let response = try await resource._poll(environmentID, blockMs: block, reclaimOlderThanMs: reclaim, anthropicWorkerID: workerID,
                                                extraHeaders: extraHeaders, _mode: .parsed)
        // An empty poll answers `null` (Python's `Optional[BetaSelfHostedWork]`).
        let data = try await response.read()
        if data.allSatisfy({ $0 == 0x20 || $0 == 0x0A || $0 == 0x0D || $0 == 0x09 }) { return nil }
        if case .null = try JSONValue.parse(data) { return nil }
        return try AnthropicJSON.decoder().decode(BetaSelfHostedWork.self, from: data)
    }

    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws {
        _ = try await resource.ack(workID, environmentID: environmentID, extraHeaders: extraHeaders)
    }

    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws {
        _ = try await resource.stop(workID, environmentID: environmentID, force: force, extraHeaders: extraHeaders)
    }

    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String,
                   extraHeaders: Headers?) async throws -> BetaSelfHostedWorkHeartbeatResponse
    {
        try await resource.heartbeat(workID, environmentID: environmentID, expectedLastHeartbeat: .some(expectedLastHeartbeat),
                                     extraHeaders: extraHeaders)
    }
}

/// Clock and sleep of the poller, replaceable in tests.
struct EnvironmentPollerHooks: Sendable {
    var now: @Sendable () -> Double = { ProcessInfo.processInfo.systemUptime }
    var sleep: @Sendable (Double) async throws -> Void = { seconds in
        try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
    }
}

func isStatus(_ error: Error, _ code: Int) -> Bool {
    (error as? APIStatusError)?.statusCode == code
}

/// Python's `str(e)` for the errors the helpers log.
func helperErrorString(_ error: Error) -> String {
    if let e = error as? AnthropicError { return e.message }
    return "\(error)"
}

private func pyBool(_ b: Bool) -> String { b ? "True" : "False" }

/// Keeps an idle poll loop visible in the logs without an INFO line per poll (`_IdleLog`): the first empty poll
/// after start-up or after a claim logs at INFO and later ones at DEBUG, with an INFO reminder every
/// `IDLE_REPORT_INTERVAL` seconds while the loop stays idle.
struct PollerIdleLog {
    let environmentID: String
    var idleSince: Double?
    var lastReport: Double = 0

    mutating func onEmptyPoll(now: Double) {
        if idleSince == nil {
            idleSince = now
            lastReport = now
            pollerLog.info("idle; polling environment_id=\(environmentID) for work")
        } else if now - lastReport >= IDLE_REPORT_INTERVAL {
            lastReport = now
            pollerLog.info("still polling environment_id=\(environmentID); idle for \(String(format: "%.0f", now - idleSince!))s")
        } else {
            pollerLog.debug("poll returned no work environment_id=\(environmentID)")
        }
    }

    mutating func onClaim() { idleSince = nil }
}

/// The documented unique worker id: the hostname with a random suffix, since several workers can share a host.
func defaultWorkerID() -> String {
    let suffix = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(12)
    return "\(localHostName())-\(suffix)"
}

/// `socket.gethostname()`: the host's name, without the name lookup that `ProcessInfo.hostName` does (which can block
/// for seconds without a network).
func localHostName() -> String {
    var buffer = [CChar](repeating: 0, count: 256)
    guard gethostname(&buffer, buffer.count) == 0 else { return "localhost" }
    return String(cString: buffer)
}

/// Work items claimed from a self-hosted environment (`aiter_work`). Each item it yields has been ack'd.
///
/// Two consumption shapes are supported:
///
/// - **Long-running runner** (`drain: false, autoStop: true`, the default): loops forever, sleeps with jitter on
///   empty polls, and stops each item once the loop body is done with it — when the next item is asked for, or
///   when the body throws out of `forEach(_:)` / the poller is `close()`d.
/// - **Drain-and-dispatch** (`drain: true, autoStop: false`): returns as soon as the queue is empty and never
///   calls `stop`: each item is handed off to another process that owns `stop`.
///
/// Transient failures (transport errors, 5xx, 408 / 409 / 429) back off and retry; any other 4xx ends the poll loop,
/// except on `ack`, where the item is force-stopped instead. Errors that are not API or transport errors
/// propagate.
///
/// ```swift
/// let poller = try client.beta.environments.work.poller(environmentID: id, environmentKey: key)
/// try await poller.forEach { work in
///     print("serving", work.data.id)
/// }
/// ```
public final class EnvironmentWorkPoller: AsyncSequence, @unchecked Sendable {
    public typealias Element = BetaSelfHostedWork

    let work: any EnvironmentWorkAPI
    public let environmentID: String
    public let workerID: String
    public let blockMs: Int?
    public let reclaimOlderThanMs: Int?
    public let drain: Bool
    public let autoStop: Bool
    public let extraHeaders: Headers?
    var hooks: EnvironmentPollerHooks

    private let lock = NSLock()
    private var outstanding: BetaSelfHostedWork?
    private var started = false
    private var finished = false
    private var pollAttempt = 0
    private var ackAttempt = 0
    private var idle: PollerIdleLog

    /// A poller over `work`, which must be bound to a client authenticated for the environment: the poller itself
    /// does not handle credentials. `client.beta.environments.work.poller(...)` builds that client for you.
    ///
    /// - Parameters:
    ///   - blockMs: How long the server holds an empty poll open. `nil` omits the param for a non-blocking poll
    ///     (the server rejects `0`).
    ///   - reclaimOlderThanMs: Reclaim un-ack'd work older than this many milliseconds.
    ///   - drain: Return after the first empty poll instead of sleeping and polling again.
    ///   - autoStop: Stop each item once the loop body is done with it.
    ///   - extraHeaders: Headers passed through on every poll / ack / stop request (never assigned onto the client).
    public convenience init(work: any EnvironmentWorkAPI, environmentID: String, workerID: String? = nil,
                            blockMs: Int? = POLL_BLOCK_MS, reclaimOlderThanMs: Int? = nil, drain: Bool = false,
                            autoStop: Bool = true, extraHeaders: Headers? = nil)
    {
        self.init(work: work, environmentID: environmentID, workerID: workerID, blockMs: blockMs,
                  reclaimOlderThanMs: reclaimOlderThanMs, drain: drain, autoStop: autoStop, extraHeaders: extraHeaders,
                  hooks: EnvironmentPollerHooks())
    }

    init(work: any EnvironmentWorkAPI, environmentID: String, workerID: String?, blockMs: Int?, reclaimOlderThanMs: Int?,
         drain: Bool, autoStop: Bool, extraHeaders: Headers?, hooks: EnvironmentPollerHooks)
    {
        self.work = work
        self.environmentID = environmentID
        self.workerID = workerID ?? defaultWorkerID()
        self.blockMs = blockMs
        self.reclaimOlderThanMs = reclaimOlderThanMs
        self.drain = drain
        self.autoStop = autoStop
        self.extraHeaders = extraHeaders
        self.hooks = hooks
        self.idle = PollerIdleLog(environmentID: environmentID)
    }

    deinit {
        // A loop left without `close()`: stop the item it was given, best-effort.
        if let item = outstanding {
            let work = self.work, environmentID = self.environmentID, extraHeaders = self.extraHeaders
            Task { await stopAfterBody(work, item, environmentID: environmentID, extraHeaders: extraHeaders) }
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let poller: EnvironmentWorkPoller
        public mutating func next() async throws -> BetaSelfHostedWork? { try await poller.next() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(poller: self) }

    /// Run `body` for each claimed item. With `autoStop`, an item is stopped once `body` returns or throws.
    public func forEach(_ body: (BetaSelfHostedWork) async throws -> Void) async throws {
        do {
            while let item = try await next() { try await body(item) }
        } catch {
            await close()
            throw error
        }
    }

    /// End the loop: the item handed out last is stopped (with `autoStop`), and no more items are claimed.
    public func close() async {
        let item: BetaSelfHostedWork? = lock.withLock {
            finished = true
            let item = outstanding
            outstanding = nil
            return item
        }
        if let item { await stopAfterBody(work, item, environmentID: environmentID, extraHeaders: extraHeaders) }
    }

    /// The next claimed and ack'd work item, or `nil` once a drain finds the queue empty.
    public func next() async throws -> BetaSelfHostedWork? {
        let previous: BetaSelfHostedWork? = lock.withLock {
            let item = outstanding
            outstanding = nil
            return item
        }
        // The loop body is done with the previous item.
        if let previous { await stopAfterBody(work, previous, environmentID: environmentID, extraHeaders: extraHeaders) }
        if lock.withLock({ finished }) { return nil }
        if !started {
            started = true
            pollerLog.info("poller starting environment_id=\(environmentID) drain=\(pyBool(drain)) auto_stop=\(pyBool(autoStop))")
        }
        do {
            return try await claim()
        } catch {
            lock.withLock { finished = true }
            throw error
        }
    }

    private func claim() async throws -> BetaSelfHostedWork? {
        // Poll and ack each have their own backoff counter, so a run of ack failures can't inflate the next poll
        // failure's backoff (and the other way round).
        while true {
            let polled: BetaSelfHostedWork?
            do {
                polled = try await work.poll(environmentID, blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, workerID: workerID,
                                             extraHeaders: extraHeaders)
            } catch let error where HelperRetry.isTransient(error) {
                if HelperRetry.isFatalStatusError(error) {
                    pollerLog.error("poll failed permanently error=\(helperErrorString(error))")
                    throw error
                }
                pollAttempt += 1
                let wait = HelperRetry.backoff(attempt: pollAttempt, cap: POLL_BACKOFF_CAP) + HelperRetry.jitter(0, 1)
                pollerLog.warning("poll failed attempt=\(pollAttempt) backoff=\(String(format: "%.1f", wait))s error=\(helperErrorString(error))")
                try await hooks.sleep(wait)
                continue
            }
            pollAttempt = 0
            guard let item = polled else {
                if drain {
                    pollerLog.info("queue drained environment_id=\(environmentID)")
                    lock.withLock { finished = true }
                    return nil
                }
                idle.onEmptyPoll(now: hooks.now())
                try await hooks.sleep(HelperRetry.jitter(1, 3))
                continue
            }
            idle.onClaim()
            pollerLog.info("claimed work work_id=\(item.id) work_type=\(item.data.type)")
            do {
                try await work.ack(item.id, environmentID: environmentID, extraHeaders: extraHeaders)
            } catch let error where HelperRetry.isTransient(error) {
                if HelperRetry.isFatalStatusError(error) {
                    pollerLog.error("ack failed permanently; force-stopping work_id=\(item.id) error=\(helperErrorString(error))")
                    await forceStopQuietly(work, item.id, environmentID: environmentID, extraHeaders: extraHeaders)
                    continue
                }
                ackAttempt += 1
                let wait = HelperRetry.backoff(attempt: ackAttempt, cap: POLL_BACKOFF_CAP) + HelperRetry.jitter(0, 1)
                pollerLog.warning(
                    "ack failed, backing off work_id=\(item.id) attempt=\(ackAttempt) backoff=\(String(format: "%.1f", wait))s error=\(helperErrorString(error))")
                try await hooks.sleep(wait)
                continue
            }
            ackAttempt = 0
            if autoStop { lock.withLock { outstanding = item } }
            return item
        }
    }
}

/// `work.stop` once the consumer is done with an item; a 409 means it already stopped.
private func stopAfterBody(_ work: any EnvironmentWorkAPI, _ item: BetaSelfHostedWork, environmentID: String,
                           extraHeaders: Headers?) async
{
    do {
        try await work.stop(item.id, environmentID: environmentID, force: nil, extraHeaders: extraHeaders)
    } catch {
        if !isStatus(error, 409) { pollerLog.warning("stop failed work_id=\(item.id) error=\(helperErrorString(error))") }
    }
}

/// Best-effort `work.stop(force: true)` for an item that can't be processed (`_aforce_stop_quietly`). A 409 just
/// means the work already stopped; anything else is logged but not raised, since the poll loop must keep going.
func forceStopQuietly(_ work: any EnvironmentWorkAPI, _ workID: String, environmentID: String, extraHeaders: Headers?) async {
    do {
        try await work.stop(workID, environmentID: environmentID, force: true, extraHeaders: extraHeaders)
    } catch {
        if !isStatus(error, 409) {
            pollerLog.error("force-stop of unprocessable work failed work_id=\(workID) error=\(helperErrorString(error))")
        }
    }
}

extension BetaEnvironmentsWorkResource {
    /// Iterate work items claimed from a self-hosted environment (`work.poller(...)`).
    ///
    /// Each item has been ack'd. The environment key authenticates the poll, ack and stop calls through a
    /// Bearer-only sub-client tagged `environments-work-poller`. See `EnvironmentWorkPoller` for the loop's shapes.
    ///
    /// - Parameters:
    ///   - environmentKey: The environment key, the Bearer credential of the poll / ack / stop requests.
    ///   - workerID: Sent on each poll. Defaults to a unique, hostname-prefixed id.
    ///   - blockMs: How long the server holds an empty poll open (at most 999). `nil` makes the poll non-blocking.
    public func poller(environmentID: String, environmentKey: String, workerID: String? = nil, blockMs: Int? = POLL_BLOCK_MS,
                       reclaimOlderThanMs: Int? = nil, drain: Bool = false, autoStop: Bool = true,
                       extraHeaders: Headers? = nil) throws -> EnvironmentWorkPoller
    {
        guard let client = client as? Anthropic else {
            throw ArgumentTypeError("The environment poller needs an Anthropic client")
        }
        let scoped = try ScopedClient.copyWithBearerAuth(client, authToken: environmentKey, helper: .environmentsWorkPoller)
        return EnvironmentWorkPoller(
            work: ResourceEnvironmentWork(resource: scoped.beta.environments.work), environmentID: environmentID, workerID: workerID,
            blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, drain: drain, autoStop: autoStop, extraHeaders: extraHeaders)
    }
}
