// Port of tests/lib/tools/test_session_runner.py.
//
// Upstream drives `SessionToolRunner` against a stand-in for `AsyncEvents`; here `FakeSessionEvents` implements
// `SessionEventsAPI`. Upstream patches module constants (`TOOL_TIMEOUT`, `SEND_BACKOFF_CAP`, ...); here they are
// the runner's `SessionRunnerTimings`.

import Foundation
import Testing
@testable import Anthropic

private func toolUse(_ id: String, _ name: String, _ input: JSONValue = [:], permission: String? = nil,
                     thread: String? = nil) -> JSONValue
{
    [
        "type": "agent.tool_use", "id": .string(id), "name": .string(name), "input": input,
        "evaluated_permission": permission.map { .string($0) } ?? .null, "session_thread_id": thread.map { .string($0) } ?? .null,
    ]
}

private func customToolUse(_ id: String, _ name: String, _ input: JSONValue = [:]) -> JSONValue {
    ["type": "agent.custom_tool_use", "id": .string(id), "name": .string(name), "input": input, "session_thread_id": nil]
}

private func toolResult(_ id: String) -> JSONValue { ["type": "user.tool_result", "tool_use_id": .string(id)] }
private func customToolResult(_ id: String) -> JSONValue { ["type": "user.custom_tool_result", "custom_tool_use_id": .string(id)] }
private func confirmation(_ id: String, _ result: String) -> JSONValue {
    ["type": "user.tool_confirmation", "id": .string("conf_\(id)"), "tool_use_id": .string(id), "result": .string(result)]
}
private func terminated() -> JSONValue { ["type": "session.status_terminated"] }
private func idle(_ stopReason: String) -> JSONValue { ["type": "session.status_idle", "stop_reason": ["type": .string(stopReason)]] }
private func idleEndTurn() -> JSONValue { idle("end_turn") }

private func apiStatusError(_ code: Int) -> APIStatusError {
    let request = HTTPRequest(method: "POST", url: URL(string: "https://api.example/x")!)
    return APIStatusError("boom", response: HTTPResponse(statusCode: code, body: Data("{}".utf8), request: request), body: nil)
}

private struct ReadError: Error {}

/// A stand-in for the events endpoints (`FakeAsyncEvents`).
final class FakeSessionEvents: SessionEventsAPI, @unchecked Sendable {
    enum StreamSpec {
        case events([JSONValue], raiseAfter: Int? = nil, raiseWith: Error? = nil)
        case fail(Error)
    }

    private let lock = NSLock()
    private var streams: [StreamSpec]
    private let listEvents: [JSONValue]
    private var listEventsPerCall: [[JSONValue]]
    private let listRaises: Error?
    private var sendFailures: [Error?]
    private(set) var sendCalls: [(sessionID: String, events: [JSONValue], extraHeaders: Headers?)] = []
    private(set) var streamCalls = 0
    private(set) var streamHeaders: [Headers?] = []
    private(set) var listHeaders: [Headers?] = []

    init(streams: [StreamSpec]? = nil, streamEvents: [JSONValue]? = nil, listEvents: [JSONValue] = [],
         listEventsPerCall: [[JSONValue]] = [], listRaises: Error? = nil, sendFailures: [Error?] = [])
    {
        self.streams = streams ?? [.events(streamEvents ?? [])]
        self.listEvents = listEvents
        self.listEventsPerCall = listEventsPerCall
        self.listRaises = listRaises
        self.sendFailures = sendFailures
    }

    var sentEvents: [JSONValue] { lock.withLock { sendCalls.map { $0.events[0] } } }
    var sendCount: Int { lock.withLock { sendCalls.count } }

    func streamEvents(_ sessionID: String, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        let next: StreamSpec = lock.withLock {
            streamCalls += 1
            streamHeaders.append(extraHeaders)
            return streams.isEmpty ? .events([]) : streams.removeFirst()
        }
        switch next {
        case .fail(let error): throw error
        case .events(let events, let raiseAfter, let raiseWith):
            return AsyncThrowingStream { continuation in
                let task = Task {
                    for (i, event) in events.enumerated() {
                        continuation.yield(event)
                        await Task.yield()
                        try? await Task.sleep(nanoseconds: 1_000_000)
                        if let raiseAfter, i + 1 == raiseAfter {
                            continuation.finish(throwing: raiseWith)
                            return
                        }
                    }
                    // Keep the connection "open" until cancelled.
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }
    }

    func listEvents(_ sessionID: String, limit: Int, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        let events: [JSONValue] = lock.withLock {
            listHeaders.append(extraHeaders)
            return listEventsPerCall.isEmpty ? listEvents : listEventsPerCall.removeFirst()
        }
        let raises = listRaises
        return AsyncThrowingStream { continuation in
            for event in events { continuation.yield(event) }
            continuation.finish(throwing: raises)
        }
    }

    func sendEvents(_ sessionID: String, events: [JSONValue], extraHeaders: Headers?) async throws {
        let failure: Error? = lock.withLock {
            let index = sendCalls.count
            sendCalls.append((sessionID, events, extraHeaders))
            return index < sendFailures.count ? sendFailures[index] : nil
        }
        if let failure { throw failure }
    }
}

private func fakeTool(_ name: String, close: (@Sendable () async throws -> Void)? = nil,
                      _ run: @escaping @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult?) -> BetaFunctionTool
{
    BetaFunctionTool(name: name, inputSchema: ["type": "object"], close: close, run)
}

private func runner(_ events: FakeSessionEvents, tools: [any BetaRunnableTool], maxIdle: TimeInterval? = nil,
                    extraHeaders: Headers? = nil, timings: SessionRunnerTimings = SessionRunnerTimings(),
                    sendRetryWindow: @escaping @Sendable () -> TimeInterval? = { nil }) -> SessionToolRunner
{
    SessionToolRunner(events: events, sessionID: "s_1", tools: tools, maxIdle: maxIdle, extraHeaders: extraHeaders,
                      timings: timings, sendRetryWindow: sendRetryWindow)
}

private func run(_ events: FakeSessionEvents, tools: [any BetaRunnableTool], maxIdle: TimeInterval? = nil,
                 extraHeaders: Headers? = nil, timings: SessionRunnerTimings = SessionRunnerTimings()) async throws -> [DispatchedToolCall]
{
    var items: [DispatchedToolCall] = []
    for try await call in runner(events, tools: tools, maxIdle: maxIdle, extraHeaders: extraHeaders, timings: timings) {
        items.append(call)
    }
    return items
}

/// Drives a runner (`asyncio.wait_for(drive(), timeout)`): `finished` is whether it ended on its own. Waits until it
/// finishes, or until it has yielded `atLeast` calls and `seconds` have passed, giving up after `limit` seconds (the
/// suite shares the machine with every other test, so the bound is generous).
private func drive(_ runner: SessionToolRunner, for seconds: TimeInterval, atLeast: Int = 0, limit: TimeInterval = 20)
    async throws -> (items: [DispatchedToolCall], finished: Bool)
{
    let seen = Box<[DispatchedToolCall]>([])
    let done = Box(false)
    let task = Task {
        for try await call in runner { seen.mutate { $0.append(call) } }
        done.value = true
    }
    let start = Date()
    var reached: Date?
    while !done.value {
        let now = Date()
        if now.timeIntervalSince(start) > limit { break }
        if reached == nil && seen.value.count >= atLeast { reached = now }
        if let reached, now.timeIntervalSince(reached) >= seconds { break }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    task.cancel()
    return (seen.value, done.value)
}

private func resultText(_ item: DispatchedToolCall) -> String {
    (item.result?["content"]?.arrayValue ?? []).filter { $0["type"] == "text" }.compactMap { $0["text"]?.stringValue }.joined()
}

private func counting(_ counter: Box<Int>, _ value: String = "ran") -> @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult? {
    { _ in
        counter.mutate { $0 += 1 }
        return .string(value)
    }
}

@Suite struct SessionRunnerTests {
    let echo = fakeTool("echo") { input in .string("got \(input["x"].map(pythonRepr) ?? "None")") }

    @Test func yieldsCompletedToolCall() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo", ["x": 42]), terminated()])
        let items = try await run(events, tools: [echo])
        #expect(items.count == 1)
        let item = try #require(items.first)
        #expect(item.toolUseID == "tu_1")
        #expect(item.name == "echo")
        #expect(item.event["input"] == ["x": 42])
        #expect(item.isError == false)
        #expect(item.posted == true)
        #expect(resultText(item) == "got 42")
        #expect(item.event["id"] == "tu_1")
        #expect(item.result?["type"] == "user.tool_result")
        #expect(item.result?["tool_use_id"] == "tu_1")
        #expect(item.result?["is_error"] == false)
        #expect(events.sendCount == 1)
        let sent = events.sentEvents[0]
        #expect(sent["type"] == "user.tool_result")
        #expect(sent["tool_use_id"] == "tu_1")
        #expect(sent["is_error"] == false)
    }

    @Test func aToolThatReturnsNonePostsNoOutputAndTheLoopGoesOn() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "silent"), toolUse("tu_2", "echo", ["x": 1]), terminated()])
        let items = try await run(events, tools: [fakeTool("silent") { _ in nil }, echo])
        #expect(items.map(\.toolUseID) == ["tu_1", "tu_2"])
        #expect(items[0].isError == false && items[0].posted)
        #expect(resultText(items[0]) == "(no output)")
        #expect(resultText(items[1]) == "got 1")
        #expect(events.sendCount == 2)
    }

    @Test func yieldsErrorForFailingTool() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "boom"), terminated()])
        let items = try await run(events, tools: [fakeTool("boom") { _ in throw RuntimeError("nope") }])
        #expect(items.count == 1)
        #expect(items[0].isError)
        #expect(items[0].posted)
        #expect(resultText(items[0]).contains("RuntimeError"))
    }

    @Test func unknownToolSkippedByDefault() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "missing"), terminated()])
        let items = try await run(events, tools: [])
        #expect(items.count == 1)
        #expect(items[0].isError == false)
        #expect(items[0].posted == false)
        #expect(items[0].result == nil)
        #expect(events.sendCount == 0)
    }

    @Test func skipsAlreadyAnsweredEvents() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "inc"), terminated()],
                                       listEvents: [toolUse("tu_1", "inc"), toolResult("tu_1")])
        let items = try await run(events, tools: [fakeTool("inc", counting(calls, "done"))])
        #expect(calls.value == 0)
        #expect(items.isEmpty)
    }

    @Test func yieldsCompletedCustomToolCall() async throws {
        let weather = fakeTool("get_weather") { input in .string("sunny in \(input["city"]?.stringValue ?? "")") }
        let events = FakeSessionEvents(streamEvents: [customToolUse("ctu_1", "get_weather", ["city": "SF"]), terminated()])
        let items = try await run(events, tools: [weather])
        let item = try #require(items.first)
        #expect(items.count == 1)
        #expect(item.toolUseID == "ctu_1")
        #expect(item.name == "get_weather")
        #expect(item.event["input"] == ["city": "SF"])
        #expect(!item.isError && item.posted)
        #expect(resultText(item) == "sunny in SF")
        #expect(item.eventType == "agent.custom_tool_use")
        #expect(item.result?["type"] == "user.custom_tool_result")
        #expect(item.result?["custom_tool_use_id"] == "ctu_1")
        #expect(item.result?["is_error"] == false)
        let sent = events.sentEvents[0]
        #expect(sent["type"] == "user.custom_tool_result")
        #expect(sent["custom_tool_use_id"] == "ctu_1")
        #expect(sent["is_error"] == false)
    }

    @Test func dispatchesBuiltinAndCustomToolsInOneStream() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo", ["x": 1]), customToolUse("ctu_1", "get_weather"), terminated()])
        let items = try await run(events, tools: [echo, fakeTool("get_weather") { _ in "sunny" }])
        let byID = Dictionary(uniqueKeysWithValues: items.map { ($0.toolUseID, $0) })
        #expect(Set(byID.keys) == ["tu_1", "ctu_1"])
        #expect(byID["tu_1"]?.eventType == "agent.tool_use")
        #expect(byID["tu_1"]?.result?["type"] == "user.tool_result")
        #expect(byID["ctu_1"]?.eventType == "agent.custom_tool_use")
        #expect(byID["ctu_1"]?.result?["type"] == "user.custom_tool_result")
        #expect(Set(events.sentEvents.compactMap { $0["type"]?.stringValue }) == ["user.tool_result", "user.custom_tool_result"])
    }

    @Test func skipsAlreadyAnsweredCustomTool() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [customToolUse("ctu_1", "get_weather"), terminated()],
                                       listEvents: [customToolUse("ctu_1", "get_weather"), customToolResult("ctu_1")])
        let items = try await run(events, tools: [fakeTool("get_weather", counting(calls, "sunny"))])
        #expect(calls.value == 0)
        #expect(items.isEmpty)
    }

    @Test func skipsUnownedBuiltinAndCustomToolsByDefault() async throws {
        let ran = Box(0)
        let events = FakeSessionEvents(streamEvents: [
            toolUse("evt_99", "not_ours"), customToolUse("cevt_99", "app_backend_tool"), toolUse("tu_ok", "echo"), terminated(),
        ])
        let items = try await run(events, tools: [fakeTool("echo", counting(ran, "ok"))])
        let byID = Dictionary(uniqueKeysWithValues: items.map { ($0.toolUseID, $0) })
        #expect(Set(byID.keys) == ["evt_99", "cevt_99", "tu_ok"])
        for id in ["evt_99", "cevt_99"] {
            #expect(byID[id]?.isError == false, "a skipped call is not an error")
            #expect(byID[id]?.posted == false, "nothing was sent for an unowned tool")
            #expect(byID[id]?.result == nil)
        }
        #expect(byID["evt_99"]?.name == "not_ours")
        #expect(byID["evt_99"]?.eventType == "agent.tool_use")
        #expect(byID["cevt_99"]?.eventType == "agent.custom_tool_use")
        #expect(byID["tu_ok"]?.posted == true)
        #expect(byID["tu_ok"]?.result?["type"] == "user.tool_result")
        #expect(ran.value == 1)
        #expect(events.sentEvents.map { $0["tool_use_id"] } == ["tu_ok"])
    }

    @Test(arguments: [(false, true), (true, true), (true, false)])
    func skippedUnownedToolDoesNotTripIdle(approved: Bool, inHistory: Bool) async throws {
        let unanswered: [JSONValue] = approved
            ? [toolUse("evt_pending", "not_ours", permission: "ask"), idleEndTurn(), confirmation("evt_pending", "allow")]
            : [toolUse("evt_pending", "not_ours"), idleEndTurn()]
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : unanswered, listEvents: inHistory ? unanswered : [])
        let (seen, finished) = try await drive(runner(events, tools: [], maxIdle: 0.1), for: 0.8, atLeast: 1)
        #expect(!finished, "an unanswered unowned call must keep the runner alive")
        #expect(seen.count >= 1, "the unowned call must still be surfaced")
        #expect(seen.first?.toolUseID == "evt_pending")
        #expect(seen.first?.posted == false)
        #expect(seen.first?.isError == false)
        #expect(seen.first?.result == nil)
        #expect(events.sendCount == 0)
    }

    // MARK: Confirmation gating

    @Test func askToolBlocksWithoutConfirmation() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "ask"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.isEmpty)
    }

    @Test func askToolExecutesAfterAllowConfirmation() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "ask"), confirmation("tu_1", "allow"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 1)
        #expect(items.count == 1)
        #expect(items.first?.confirmation == "allow")
        #expect(items.first.map(resultText) == "ran")
        #expect(events.sentEvents.map { $0["tool_use_id"] } == ["tu_1"])
    }

    @Test func askToolDeniedNeverExecutes() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "ask"), confirmation("tu_1", "deny"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.count == 1)
        #expect(items.first?.confirmation == "deny")
        #expect(items.first?.posted == false)
        #expect(items.first?.result == nil)
        #expect(items.first?.isError == false)
    }

    @Test func preDeniedToolNeverExecutes() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "deny"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.map(\.confirmation) == ["deny"])
    }

    @Test func confirmationInHistoryReleasesAskCall() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [terminated()],
                                       listEvents: [toolUse("tu_1", "gated", permission: "ask"), confirmation("tu_1", "allow")])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 1)
        #expect(items.map(\.confirmation) == ["allow"])
    }

    @Test func deniedAskCallDoesNotBlockIdleStop() async throws {
        let events = FakeSessionEvents(streamEvents: [], listEvents: [
            toolUse("tu_1", "gated", permission: "ask"), confirmation("tu_1", "deny"), idleEndTurn(),
        ])
        let (items, finished) = try await drive(runner(events, tools: [], maxIdle: 0.05), for: 2)
        #expect(finished)
        #expect(items.map(\.confirmation) == ["deny"])
        #expect(events.sendCount == 0)
    }

    @Test(arguments: [true, false])
    func heldAskCallKeepsRunnerAlive(inHistory: Bool) async throws {
        // `in_history: true` is `test_held_ask_call_keeps_runner_alive`, `false` `test_live_idle_while_call_held_keeps_runner_alive`.
        let calls = Box(0)
        let script = [toolUse("tu_1", "gated", permission: "ask"), idleEndTurn()]
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : script, listEvents: inHistory ? script : [])
        let (_, finished) = try await drive(runner(events, tools: [fakeTool("gated", counting(calls))], maxIdle: 0.1), for: 0.8)
        #expect(!finished)
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
    }

    @Test func reconnectDoesNotDoubleDispatchHeldCall() async throws {
        let calls = Box(0)
        let gated = toolUse("tu_1", "gated", permission: "ask")
        let events = FakeSessionEvents(
            streams: [.events([gated], raiseAfter: 1, raiseWith: APIConnectionError(request: nil)), .events([terminated()])],
            listEventsPerCall: [[], [gated, confirmation("tu_1", "allow")]],
            sendFailures: [apiStatusError(400)])
        var timings = SessionRunnerTimings()
        timings.streamBackoffStart = 0.01
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))], timings: timings)
        #expect(calls.value == 1, "the confirmed call must be dispatched exactly once")
        #expect(items.filter { $0.toolUseID == "tu_1" }.count == 1)
    }

    @Test func reconcileConfirmationReleasesCallHeldFromLiveStream() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(
            streams: [
                .events([toolUse("tu_1", "gated", permission: "ask")], raiseAfter: 1, raiseWith: APIConnectionError(request: nil)),
                .events([terminated()]),
            ],
            listEventsPerCall: [[], [confirmation("tu_1", "allow")]])
        var timings = SessionRunnerTimings()
        timings.streamBackoffStart = 0.01
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))], timings: timings)
        #expect(calls.value == 1)
        #expect(items.map(\.confirmation) == ["allow"])
    }

    @Test func heldAskCallDoesNotBlockOtherDispatches() async throws {
        let events = FakeSessionEvents(streamEvents: [
            toolUse("tu_gated", "gated", permission: "ask"), toolUse("tu_echo", "echo"), confirmation("tu_gated", "allow"), terminated(),
        ])
        let items = try await run(events, tools: [fakeTool("echo") { _ in "echo" }, fakeTool("gated") { _ in "gated" }])
        let byID = Dictionary(uniqueKeysWithValues: items.map { ($0.toolUseID, $0) })
        #expect(Set(byID.keys) == ["tu_gated", "tu_echo"])
        #expect(byID["tu_gated"]?.confirmation == "allow")
        #expect(events.sentEvents.map { $0["tool_use_id"] } == ["tu_echo", "tu_gated"])
    }

    @Test func confirmationForUnknownIDIsIgnored() async throws {
        let events = FakeSessionEvents(streamEvents: [confirmation("tu_missing", "allow"), terminated()])
        let items = try await run(events, tools: [])
        #expect(items.isEmpty)
        #expect(events.sendCount == 0)
    }

    @Test func unrecognisedVerdictFailsClosed() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "ask"), confirmation("tu_1", "escalate"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 0, "only an explicit allow may release a gated call")
        #expect(events.sendCount == 0)
        #expect(items.map(\.confirmation) == ["deny"])
    }

    @Test func unrecognisedPermissionFailsClosed() async throws {
        let calls = Box(0)
        let tool = fakeTool("gated", counting(calls))
        let first = FakeSessionEvents(streamEvents: [toolUse("tu_1", "gated", permission: "ask_strict"), terminated()])
        #expect(try await run(first, tools: [tool]).isEmpty)
        #expect(calls.value == 0)
        let second = FakeSessionEvents(streamEvents: [
            toolUse("tu_2", "gated", permission: "ask_strict"), confirmation("tu_2", "allow"), terminated(),
        ])
        #expect(try await run(second, tools: [tool]).count == 1)
        #expect(calls.value == 1)
    }

    @Test func preDeniedToolIgnoresStrayAllowVerdict() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [confirmation("tu_1", "allow"), toolUse("tu_1", "gated", permission: "deny"), terminated()])
        let items = try await run(events, tools: [fakeTool("gated", counting(calls))])
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.map(\.confirmation) == ["deny"])
    }

    @Test func ungatedToolWithStrayDenyVerdictResolvesAsDenied() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [confirmation("tu_1", "deny"), toolUse("tu_1", "echo"), terminated()])
        let items = try await run(events, tools: [fakeTool("echo", counting(calls))])
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.map(\.confirmation) == ["deny"])
    }

    @Test(arguments: [false, true])
    func denyAfterEndTurnResumesIdleStop(inHistory: Bool) async throws {
        let calls = Box(0)
        let script = [toolUse("tu_1", "gated", permission: "ask"), idleEndTurn(), confirmation("tu_1", "deny")]
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : script, listEvents: inHistory ? script : [])
        let (items, finished) = try await drive(runner(events, tools: [fakeTool("gated", counting(calls))], maxIdle: 0.05), for: 2)
        #expect(finished)
        #expect(calls.value == 0)
        #expect(events.sendCount == 0)
        #expect(items.map(\.confirmation) == ["deny"])
    }

    @Test(arguments: [false, true])
    func allowAfterEndTurnResumesIdleStop(inHistory: Bool) async throws {
        let script = [toolUse("tu_1", "gated", permission: "ask"), idleEndTurn(), confirmation("tu_1", "allow")]
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : script, listEvents: inHistory ? script : [])
        let (items, finished) = try await drive(runner(events, tools: [fakeTool("gated") { _ in "ran" }], maxIdle: 0.05), for: 2)
        #expect(finished)
        #expect(items.map(\.confirmation) == ["allow"])
        #expect(events.sendCount == 1)
    }

    @Test func reconcileReleasedCallNotCutShortByIdle() async throws {
        let maxIdle = 0.4
        let calls = Box(0)
        let postedAt = Box<Date?>(nil)
        let slow = fakeTool("gated") { _ in
            calls.mutate { $0 += 1 }
            try await Task.sleep(nanoseconds: 600_000_000)
            postedAt.value = Date()
            return "ran"
        }
        let events = FakeSessionEvents(
            streams: [
                .events([toolUse("tu_1", "gated", permission: "ask")], raiseAfter: 1, raiseWith: APIConnectionError(request: nil)),
                .events([]),
            ],
            // The reconcile after the reconnect sees only the verdict and the idle.
            listEventsPerCall: [[], [confirmation("tu_1", "allow"), idleEndTurn()]])
        var timings = SessionRunnerTimings()
        timings.streamBackoffStart = 0.01
        let (seen, finished) = try await drive(runner(events, tools: [slow], maxIdle: maxIdle, timings: timings), for: 4)
        let stoppedAt = Date()
        #expect(finished)
        #expect(calls.value == 1)
        #expect(seen.map(\.confirmation) == ["allow"])
        if let posted = postedAt.value { #expect(stoppedAt.timeIntervalSince(posted) > maxIdle * 0.6) }
    }

    @Test(arguments: ["end_turn", "refusal", "retries_exhausted", "budget_reached", "newer_than_this_sdk"], [false, true])
    func idleAfterTurnEndsEndsIteration(stopReason: String, inHistory: Bool) async throws {
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : [idle(stopReason)], listEvents: inHistory ? [idle(stopReason)] : [])
        let (items, finished) = try await drive(runner(events, tools: [], maxIdle: 0.05), for: 2)
        #expect(finished)
        #expect(items.isEmpty)
    }

    @Test(arguments: [false, true])
    func requiresActionIdleDoesNotEndIteration(inHistory: Bool) async throws {
        let events = FakeSessionEvents(streamEvents: inHistory ? [] : [idle("requires_action")],
                                       listEvents: inHistory ? [idle("requires_action")] : [])
        let (_, finished) = try await drive(runner(events, tools: [], maxIdle: 0.05), for: 0.5)
        #expect(!finished)
    }

    @Test func idleGraceDoesNotFireWithoutEndTurn() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo", ["x": 1]), terminated()])
        let items = try await run(events, tools: [echo], maxIdle: 0.05)
        #expect(items.map(\.toolUseID) == ["tu_1"])
    }

    @Test func newEventResetsIdleGrace() async throws {
        let events = FakeSessionEvents(streamEvents: [idleEndTurn(), toolUse("tu_1", "echo", ["x": 1]), terminated()])
        let items = try await run(events, tools: [echo], maxIdle: 5)
        #expect(items.map(\.toolUseID) == ["tu_1"])
    }

    @Test func terminatedEventEndsIteration() async throws {
        #expect(try await run(FakeSessionEvents(streamEvents: [terminated()]), tools: []).isEmpty)
    }

    // MARK: Tool cleanup

    @Test func runsToolCloseHookOnExit() async throws {
        let closed = Box(0)
        let tool = fakeTool("echo", close: { closed.mutate { $0 += 1 } }) { _ in "ok" }
        _ = try await run(FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()]), tools: [tool])
        #expect(closed.value == 1)
    }

    @Test func runsContextManagerToolCleanupOnExit() async throws {
        let seen = Box<[String]>([])
        let tool = BetaFunctionTool(name: "echo", inputSchema: ["type": "object"], enter: {
            seen.mutate { $0.append("enter") }
            let f: BetaFunctionTool.Function = { input in .string("echo:\(input["command"]?.stringValue ?? "None")") }
            return (f, { seen.mutate { $0.append("exit") } })
        })
        let calls = try await run(FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo", ["command": "hi"]), terminated()]), tools: [tool])
        #expect(calls.map(resultText) == ["echo:hi"])
        #expect(seen.value == ["enter", "exit"])
    }

    // MARK: Sending results

    @Test func sendRetriesPastThreeAttempts() async throws {
        var timings = SessionRunnerTimings()
        timings.sendBackoffCap = 0.02
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()], sendFailures: Array(repeating: apiStatusError(503), count: 6))
        let items = try await run(events, tools: [fakeTool("echo") { _ in "result" }], timings: timings)
        #expect(items.count == 1)
        #expect(items.first?.posted == true)
        #expect(events.sendCount == 7)
    }

    @Test func yieldsWithPostedFalseOnRetryWindowExhaust() async throws {
        var timings = SessionRunnerTimings()
        timings.sendBackoffCap = 0.05
        timings.sendRetryWindow = 0.5
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()], sendFailures: Array(repeating: apiStatusError(500), count: 100))
        let start = Date()
        let items = try await run(events, tools: [fakeTool("echo") { _ in "result" }], timings: timings)
        let elapsed = Date().timeIntervalSince(start)
        #expect(items.count == 1)
        #expect(items.first?.posted == false)
        #expect(items.first.map(resultText) == "result")
        #expect(events.sendCount >= 3)
        #expect(elapsed >= 0.5 && elapsed < 5)
    }

    @Test func sendRetryWindowUpdateBoundsSendAlreadyRetrying() async throws {
        var timings = SessionRunnerTimings()
        timings.sendBackoffCap = 0.05
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()], sendFailures: Array(repeating: apiStatusError(503), count: 10_000))
        let start = Date()
        var items: [DispatchedToolCall] = []
        for try await call in runner(events, tools: [fakeTool("echo") { _ in "result" }], timings: timings, sendRetryWindow: { 0.2 }) {
            items.append(call)
        }
        #expect(items.count == 1)
        #expect(items.first?.posted == false)
        #expect(Date().timeIntervalSince(start) < 10)
    }

    @Test func yieldsWithPostedFalseOnPermanent4xx() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()], sendFailures: [apiStatusError(400)])
        let items = try await run(events, tools: [fakeTool("echo") { _ in "result" }])
        #expect(items.count == 1)
        #expect(items.first?.posted == false)
        #expect(events.sendCount == 1)
    }

    // MARK: Tool execution edge cases

    @Test func toolTimeout() async throws {
        var timings = SessionRunnerTimings()
        timings.toolTimeout = 0.05
        let slow = fakeTool("slow") { _ in
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return "never"
        }
        let items = try await run(FakeSessionEvents(streamEvents: [toolUse("tu_1", "slow"), terminated()]), tools: [slow], timings: timings)
        #expect(items.count == 1)
        #expect(items.first?.isError == true)
        #expect(items.first.map(resultText)?.contains("timed out") == true)
    }

    @Test func toolTimeoutFiresForAToolThatIgnoresCancellation() async throws {
        var timings = SessionRunnerTimings()
        timings.toolTimeout = 0.05
        let release = Box(false)
        let blocking = fakeTool("slow") { _ in
            while !release.value { usleep(10_000) }
            return "late"
        }
        defer { release.value = true }
        let events = FakeSessionEvents(streamEvents: [customToolUse("ctu_1", "slow"), terminated()])
        let items = try await run(events, tools: [blocking], timings: timings)
        release.value = true
        #expect(items.count == 1)
        #expect(items.first?.isError == true)
        #expect(items.first.map(resultText)?.contains("timed out") == true)
        #expect(events.sendCount == 1)
    }

    @Test func toolTimeoutExceedsBashDefault() {
        #expect(TOOL_TIMEOUT > 120)
    }

    @Test func toolErrorPreservesStructuredContent() async throws {
        let structured: JSONValue = [["type": "text", "text": "structured error"]]
        let boom = fakeTool("boom") { _ in throw ToolError(try structured.decode(as: BetaFunctionToolResult.self)) }
        let items = try await run(FakeSessionEvents(streamEvents: [toolUse("tu_1", "boom"), terminated()]), tools: [boom])
        #expect(items.count == 1)
        #expect(items.first?.isError == true)
        #expect(items.first?.result?["content"] == structured)
    }

    // MARK: Stream loop edge cases

    @Test func streamPermanent4xxEndsIteration() async throws {
        let events = FakeSessionEvents(streams: [.fail(apiStatusError(401))])
        #expect(try await run(events, tools: []).isEmpty)
        #expect(events.streamCalls == 1)
    }

    @Test func reconcileListErrorDoesNotDispatchPartial() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [terminated()], listEvents: [toolUse("tu_1", "inc")], listRaises: apiStatusError(500))
        let items = try await run(events, tools: [fakeTool("inc", counting(calls, "done"))])
        #expect(items.isEmpty)
        #expect(calls.value == 0)
    }

    @Test func sessionRunnerThreadsExtraHeadersIntoStreamListAndSend() async throws {
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()])
        let extras: Headers = ["x-trace-id": "abc123"]
        _ = try await run(events, tools: [fakeTool("echo") { _ in "ok" }], extraHeaders: extras)
        #expect(events.streamHeaders.first == extras)
        #expect(events.listHeaders.first == extras)
        #expect(events.sendCalls.first?.extraHeaders == extras)
    }

    @Test func untilDoneDrivesRunnerToCompletion() async throws {
        let calls = Box(0)
        let events = FakeSessionEvents(streamEvents: [toolUse("tu_1", "echo"), terminated()])
        try await runner(events, tools: [fakeTool("echo", counting(calls, "ok"))]).untilDone()
        #expect(calls.value == 1)
        #expect(events.sendCount == 1)
    }

    @Test func toolRunnerMethodReturnsSessionToolRunner() throws {
        let client = try Anthropic(apiKey: "dummy", environment: [:])
        let runner = try client.beta.sessions.events.toolRunner("s_1", tools: [])
        #expect(runner.sessionID == "s_1")
    }

    // MARK: _to_session_content

    @Test func toSessionContentPassthrough() {
        #expect(toSessionContent([["type": "text", "text": "hello"]]) == [["type": "text", "text": "hello"]])
        let image: JSONValue = ["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": "QUJD"]]
        #expect(toSessionContent([image]) == [image])
        let document: JSONValue = ["type": "document", "source": ["type": "url", "url": "https://example.com/doc.pdf"], "title": "doc"]
        #expect(toSessionContent([document]) == [document])
        let search: JSONValue = [
            "type": "search_result", "source": "https://example.com", "title": "t", "content": [["type": "text", "text": "x"]],
        ]
        #expect(toSessionContent([search]) == [search])
    }

    @Test func toSessionContentToolReferenceStringified() {
        let out = toSessionContent([["type": "tool_reference", "tool_name": "x"]])
        #expect(out.count == 1)
        #expect(out[0]["type"] == "text")
        #expect(out[0]["text"] == .string(#"{"tool_name": "x", "type": "tool_reference"}"#))
    }
}

/// The runner against the real events resource over a mock transport: the environment key authenticates every
/// request (`test_environment_key_threads_through_to_scoped_client` checks the same through a patched factory).
@Suite struct SessionRunnerHTTPTests {
    @Test(arguments: [true, false])
    func environmentKeyAuthenticatesTheRunnersRequests(withKey: Bool) async throws {
        let requests = Box<[HTTPRequest]>([])
        let toolUse = #"{"type":"agent.tool_use","id":"tu_1","name":"echo","input":{},"processed_at":"2026-01-01T00:00:00Z"}"#
        let end = #"{"type":"session.status_terminated","id":"ev_2","processed_at":"2026-01-01T00:00:00Z"}"#
        let transport = MockTransport { request in
            requests.mutate { $0.append(request) }
            let path = request.url.path
            if path.hasSuffix("/events/stream") {
                return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"],
                                    stream: chunked(Data("event: message\ndata: \(toolUse)\n\nevent: message\ndata: \(end)\n\n".utf8)), request: request)
            }
            if request.method == "GET" { return HTTPResponse.json(["data": [], "next_page": nil], for: request) }
            return HTTPResponse.json(["data": []], for: request)
        }
        let client = try Anthropic(apiKey: "sk-test", baseURL: testBaseURL, maxRetries: 0, transport: transport, environment: [:])
        let runner = try client.beta.sessions.events.toolRunner(
            "s_1", tools: [fakeTool("echo") { _ in "ok" }], maxIdle: nil, environmentKey: withKey ? "env_key" : nil,
            extraHeaders: ["x-trace-id": "abc123"])
        var calls: [DispatchedToolCall] = []
        for try await call in runner { calls.append(call) }
        #expect(calls.map(\.posted) == [true])
        let sent = requests.value
        #expect(sent.count == 3)
        for request in sent {
            #expect(request.headers["Authorization"] == (withKey ? "Bearer env_key" : "Bearer sk-test"))
            #expect(request.headers["x-stainless-helper"] == "session-tool-runner")
            #expect(request.headers["x-trace-id"] == "abc123")
        }
        let post = try #require(sent.first { $0.method == "POST" })
        #expect(post.jsonBody?["events"]?[0]?["type"] == "user.tool_result")
        #expect(post.jsonBody?["events"]?[0]?["tool_use_id"] == "tu_1")
    }
}
