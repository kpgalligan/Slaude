// Port of `anthropic/lib/tools/_beta_session_runner.py`: the sessions-side tool runner, the managed-agents
// counterpart to `client.beta.messages.toolRunner`.
//
// `SessionToolRunner` attaches to a session's event stream, reconciles against the events-list endpoint, dispatches
// every `agent.tool_use` and `agent.custom_tool_use` event against a local tool registry, posts the matching result
// event back (`user.tool_result` / `user.custom_tool_result`), and yields one `DispatchedToolCall` per completed call.
// A call the server gated behind user confirmation (`evaluated_permission: "ask"`) is held until its
// `user.tool_confirmation` event arrives: executed on `allow`, never on `deny`. It stops itself once the session has
// been idle (any `stop_reason` but `requires_action`) for `maxIdle` seconds.
//
// Python runs the loops in an anyio task group on one event loop; here they are tasks over one actor, which
// interleaves them at the same suspension points.

import Foundation

/// The anthropic-beta gating Sessions access to self-hosted environments.
public let MANAGED_AGENTS_BETA = "managed-agents-2026-04-01"

/// The default grace period, in seconds, the runner keeps running after the session's turn ends.
public let DEFAULT_MAX_IDLE: TimeInterval = 60

/// The outer per-tool-call timeout. It must stay strictly greater than the bash tool's own timeout (120s).
public let TOOL_TIMEOUT: TimeInterval = 150

/// The timings of a session tool runner (upstream's module constants, which its tests patch).
struct SessionRunnerTimings: Sendable {
    var streamBackoffStart: TimeInterval = 0.5
    var streamBackoffCap: TimeInterval = 10
    var toolTimeout: TimeInterval = TOOL_TIMEOUT
    /// Cap on the exponential backoff between tool-result send retries.
    var sendBackoffCap: TimeInterval = 30
    /// How long a transiently failing tool-result send keeps retrying (the server's default lease TTL).
    var sendRetryWindow: TimeInterval = 300
}

/// One tool call observed by `SessionToolRunner` (`DispatchedToolCall`).
public struct DispatchedToolCall: Sendable, Hashable {
    /// The full `agent.tool_use` / `agent.custom_tool_use` event. The tool input is `event["input"]`.
    public let event: JSONValue
    /// The result event the runner computed and attempted to post (`user.tool_result` /
    /// `user.custom_tool_result`); `nil` when it deliberately posted nothing (an unowned or denied call).
    public let result: JSONValue?
    /// The id of the originating tool-call event.
    public let toolUseID: String
    /// The tool name.
    public let name: String
    /// Whether the result is an error.
    public let isError: Bool
    /// Whether the result event made it to the session.
    public let posted: Bool
    /// The confirmation verdict that gated this call (`"allow"` / `"deny"`), if any.
    public let confirmation: String?

    /// The event's type (`agent.tool_use` or `agent.custom_tool_use`).
    public var eventType: String { event["type"]?.stringValue ?? "" }

    /// The event as the generated `agent.tool_use` model, when it is one.
    public var toolUseEvent: BetaManagedAgentsAgentToolUseEvent? { try? event.decode() }

    /// The event as the generated `agent.custom_tool_use` model, when it is one.
    public var customToolUseEvent: BetaManagedAgentsAgentCustomToolUseEvent? { try? event.decode() }
}

/// The events endpoints a session tool runner reads and writes, with events as JSON. The generated
/// `BetaSessionsEventsResource` provides them; tests substitute a fake.
public protocol SessionEventsAPI: Sendable {
    /// The session's event history, every page.
    func listEvents(_ sessionID: String, limit: Int, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error>
    /// The session's live event stream.
    func streamEvents(_ sessionID: String, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error>
    /// Posts events to the session.
    func sendEvents(_ sessionID: String, events: [JSONValue], extraHeaders: Headers?) async throws
}

/// `SessionEventsAPI` over the generated resource.
struct ResourceSessionEvents: SessionEventsAPI {
    let resource: BetaSessionsEventsResource

    func listEvents(_ sessionID: String, limit: Int, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        let page = try await resource.list(sessionID, limit: limit, extraHeaders: extraHeaders)
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await event in page { continuation.yield(try JSONValue.from(event)) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func streamEvents(_ sessionID: String, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        let stream = try await resource.stream(sessionID, extraHeaders: extraHeaders)
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await event in stream { continuation.yield(try JSONValue.from(event)) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func sendEvents(_ sessionID: String, events: [JSONValue], extraHeaders: Headers?) async throws {
        let params: [BetaManagedAgentsEventParams] = try events.map { try $0.decode() }
        _ = try await resource.send(sessionID, events: params, extraHeaders: extraHeaders)
    }
}

let sessionLog = ToolLogger(name: "anthropic.lib.tools._beta_session_runner")

/// Whether `error` is worth retrying (`TRANSIENT_ERRORS`): an API error or a transport failure.
func isTransientError(_ error: Error) -> Bool {
    if error is APIError || error is TransportTimeoutError || error is URLError { return true }
    return false
}

/// A 4xx that retrying will not fix (`is_fatal_status_error`); 408 / 409 / 429 are transient.
func isFatalStatusError(_ error: Error) -> Bool {
    guard let e = error as? APIStatusError else { return false }
    return (400..<500).contains(e.statusCode) && ![408, 409, 429].contains(e.statusCode)
}

/// Exponential backoff for `attempt` (1-indexed), capped at `cap`.
func retryBackoff(_ attempt: Int, cap: TimeInterval, base: Double = 2) -> TimeInterval {
    min(cap, pow(base, Double(attempt)))
}

/// Whether `event` is a `session.status_idle` whose turn is over (`ends_turn`): only `requires_action` leaves the
/// turn open.
func endsTurn(_ event: JSONValue) -> Bool {
    guard event["type"] == "session.status_idle" else { return false }
    return event["stop_reason"]?["type"] != "requires_action"
}

/// Bridges Messages-API tool-result content to the Sessions-API content union (`_to_session_content`): text,
/// image, document and search_result blocks pass through; anything else is stringified. `nil` reads `(no output)`.
func toSessionContent(_ content: JSONValue) -> [JSONValue] {
    switch content {
    case .null: return toSessionContent("(no output)")
    case .string(let s): return [["type": "text", "text": .string(s.isEmpty ? "(no output)" : s)]]
    case .array(let blocks):
        var out: [JSONValue] = []
        for block in blocks {
            switch block["type"]?.stringValue {
            case "text":
                let text = block["text"]?.stringValue ?? ""
                out.append(["type": "text", "text": .string(text.isEmpty ? "(no output)" : text)])
            case "image", "document", "search_result":
                out.append(block)
            default:
                out.append(["type": "text", "text": .string(pythonJSONDumps(block))])
            }
        }
        return out.isEmpty ? toSessionContent("(no output)") : out
    default: return toSessionContent(.string(content.description))
    }
}

/// Python's `json.dumps(value)` (`", "` / `": "` separators, insertion order approximated by sorted keys,
/// non-ASCII escaped).
func pythonJSONDumps(_ value: JSONValue) -> String {
    switch value {
    case .null: return "null"
    case .bool(let b): return b ? "true" : "false"
    case .int(let i): return String(i)
    case .double(let d): return pythonFloatString(d)
    case .string(let s):
        var out = "\""
        for scalar in s.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            default:
                if scalar.value < 0x20 || scalar.value > 0x7E {
                    if scalar.value > 0xFFFF {
                        let v = scalar.value - 0x10000
                        out += String(format: "\\u%04x\\u%04x", 0xD800 + (v >> 10), 0xDC00 + (v & 0x3FF))
                    } else {
                        out += String(format: "\\u%04x", scalar.value)
                    }
                } else {
                    out.unicodeScalars.append(scalar)
                }
            }
        }
        return out + "\""
    case .array(let a): return "[" + a.map(pythonJSONDumps).joined(separator: ", ") + "]"
    case .object(let o):
        return "{" + o.sorted { $0.key < $1.key }.map { "\(pythonJSONDumps(.string($0.key))): \(pythonJSONDumps($0.value))" }
            .joined(separator: ", ") + "}"
    }
}

/// The result-event params matching the tool-call event's kind.
func buildResultEvent(_ event: JSONValue, _ content: [JSONValue], isError: Bool) -> JSONValue {
    let id = event["id"] ?? .null
    if event["type"] == "agent.custom_tool_use" {
        return ["type": "user.custom_tool_result", "custom_tool_use_id": id, "is_error": .bool(isError), "content": .array(content)]
    }
    return ["type": "user.tool_result", "tool_use_id": id, "is_error": .bool(isError), "content": .array(content)]
}

/// Attach to a managed-agents session and dispatch its tool calls locally (`SessionToolRunner`).
///
/// An async sequence of `DispatchedToolCall`. Iteration ends when the session terminates, when the consumer stops
/// iterating, or once the session has gone idle with any `stop_reason` but `requires_action` and `maxIdle` seconds
/// pass with no new event. On exit it runs each tool's optional cleanup (`closeTool()`).
///
/// A tool-call event whose name is not in `tools` is assumed to belong to another client servicing the session:
/// the runner posts nothing for it and leaves it pending, but still yields it (`posted: false`, `result: nil`).
///
/// ```swift
/// for try await call in client.beta.sessions.events.toolRunner(sessionID, tools: [myTool]) {
///     print("\(call.name) -> \(call.isError ? "error" : "ok")")
/// }
/// ```
public final class SessionToolRunner: AsyncSequence, Sendable {
    public typealias Element = DispatchedToolCall

    public let sessionID: String
    public let tools: [any BetaRunnableTool]
    public let maxIdle: TimeInterval?
    public let extraHeaders: Headers?
    let events: any SessionEventsAPI
    let timings: SessionRunnerTimings
    /// Override for the send retry window, re-read before every retry (the environment worker's lease TTL).
    let sendRetryWindow: @Sendable () -> TimeInterval?

    /// - Parameters:
    ///   - environmentKey: Authenticates the runner's requests with this Bearer credential (a self-hosted
    ///     environment key) in place of the client's own.
    ///   - extraHeaders: Headers threaded into every event stream / list / send request.
    public convenience init(client: Anthropic, sessionID: String, tools: [any BetaRunnableTool],
                            maxIdle: TimeInterval? = DEFAULT_MAX_IDLE, environmentKey: String? = nil,
                            extraHeaders: Headers? = nil) throws
    {
        let scoped = try sessionScopedClient(client, environmentKey: environmentKey)
        self.init(events: ResourceSessionEvents(resource: scoped.beta.sessions.events), sessionID: sessionID, tools: tools,
                  maxIdle: maxIdle, extraHeaders: extraHeaders)
    }

    /// A runner over any implementation of the events endpoints.
    public convenience init(events: any SessionEventsAPI, sessionID: String, tools: [any BetaRunnableTool],
                            maxIdle: TimeInterval? = DEFAULT_MAX_IDLE, extraHeaders: Headers? = nil)
    {
        self.init(events: events, sessionID: sessionID, tools: tools, maxIdle: maxIdle, extraHeaders: extraHeaders,
                  timings: SessionRunnerTimings(), sendRetryWindow: { nil })
    }

    init(events: any SessionEventsAPI, sessionID: String, tools: [any BetaRunnableTool], maxIdle: TimeInterval?,
         extraHeaders: Headers?, timings: SessionRunnerTimings, sendRetryWindow: @escaping @Sendable () -> TimeInterval?)
    {
        self.events = events
        self.sessionID = sessionID
        self.tools = tools
        self.maxIdle = maxIdle
        self.extraHeaders = extraHeaders
        self.timings = timings
        self.sendRetryWindow = sendRetryWindow
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<DispatchedToolCall, Error>.AsyncIterator {
        run().makeAsyncIterator()
    }

    /// Drives the runner to completion, discarding the per-call observations (`until_done()`).
    public func untilDone() async throws {
        for try await _ in self {}
    }

    /// Starts one run: the calls it dispatches, ending once it stops and every tool has been closed.
    func run() -> AsyncThrowingStream<DispatchedToolCall, Error> {
        let (results, resultsContinuation) = AsyncThrowingStream<DispatchedToolCall, Error>.makeStream()
        let core = SessionRunCore(runner: self, results: resultsContinuation)
        let tools = self.tools
        let maxIdle = self.maxIdle
        let driver = Task {
            sessionLog.info("session tool runner starting session_id=\(sessionID)")
            let stream = Task { await core.streamLoop() }
            let watchdog = maxIdle.map { idle in Task { await core.idleWatchdog(idle) } }
            await core.dispatchLoop()
            stream.cancel()
            watchdog?.cancel()
            _ = await stream.value
            _ = await watchdog?.value
            for tool in tools { await acloseRunnableTool(tool) }
            resultsContinuation.finish(throwing: await core.failure)
        }
        resultsContinuation.onTermination = { _ in
            Task { await core.stop() }
            _ = driver
        }
        return results
    }
}

/// The runner's request client: Bearer-only with an environment key, otherwise the caller's client with the
/// helper-telemetry header layered on.
func sessionScopedClient(_ client: Anthropic, environmentKey: String?) throws -> Anthropic {
    let helper: Headers = [STAINLESS_HELPER_HEADER: "session-tool-runner"]
    if let environmentKey {
        return try client.copy(authToken: environmentKey, defaultHeaders: helper)
    }
    return try client.copy(defaultHeaders: helper)
}

extension BetaSessionsEventsResource {
    /// Attach to a managed-agents session and dispatch its tool calls locally (`events.tool_runner(...)`).
    public func toolRunner(_ sessionID: String, tools: [any BetaRunnableTool], maxIdle: TimeInterval? = DEFAULT_MAX_IDLE,
                           environmentKey: String? = nil, extraHeaders: Headers? = nil) throws -> SessionToolRunner
    {
        guard let client = client as? Anthropic else {
            throw ArgumentTypeError("The session tool runner needs an Anthropic client")
        }
        return try SessionToolRunner(client: client, sessionID: sessionID, tools: tools, maxIdle: maxIdle,
                                     environmentKey: environmentKey, extraHeaders: extraHeaders)
    }
}

/// The state of one run and the loops that share it (Python's per-run attributes and `_stream_loop`,
/// `_dispatch_loop`, `_reconcile`, `_idle_watchdog`).
actor SessionRunCore {
    private let runner: SessionToolRunner
    private let results: AsyncThrowingStream<DispatchedToolCall, Error>.Continuation
    private let work: AsyncStream<(JSONValue, String?)>
    private let workContinuation: AsyncStream<(JSONValue, String?)>.Continuation
    private var toolsByName: [String: any BetaRunnableTool] = [:]

    private var seen = Set<String>()
    private var answered = Set<String>()
    private var confirmations: [String: String] = [:]
    private var awaitingConfirmation = OrderedDict<JSONValue>()
    private var primaryThreadID: String?
    private var historyRead = false
    private var stopped = false
    private var stopWaiters: [CheckedContinuation<Void, Never>] = []
    /// An error that ends the run and reaches the consumer.
    private(set) var failure: Error?

    // The idle clock (`_IdleClock`).
    private var turnEndedAt: TimeInterval?
    private var holds = 0
    private var armDeferred = false
    private var wakeWaiters: [CheckedContinuation<Void, Never>] = []

    init(runner: SessionToolRunner, results: AsyncThrowingStream<DispatchedToolCall, Error>.Continuation) {
        self.runner = runner
        self.results = results
        (work, workContinuation) = AsyncStream<(JSONValue, String?)>.makeStream()
        for tool in runner.tools { toolsByName[tool.name] = tool }
    }

    func stop() {
        if stopped { return }
        stopped = true
        workContinuation.finish()
        for w in stopWaiters { w.resume() }
        stopWaiters = []
        signal()
    }

    private func now() -> TimeInterval { ProcessInfo.processInfo.systemUptime }

    // MARK: Idle clock

    private func signal() {
        let waiters = wakeWaiters
        wakeWaiters = []
        for w in waiters { w.resume() }
    }

    private func noteEvent(_ event: JSONValue) {
        if event["type"] == "user.tool_confirmation" { return }
        if endsTurn(event) { arm() } else { disarm() }
    }

    private func arm() {
        if holds > 0 {
            armDeferred = true
            return
        }
        turnEndedAt = now()
        signal()
    }

    private func disarm() {
        armDeferred = false
        if turnEndedAt != nil {
            turnEndedAt = nil
            signal()
        }
    }

    private func hold() {
        holds += 1
        if turnEndedAt != nil {
            armDeferred = true
            turnEndedAt = nil
            signal()
        }
    }

    private func release() {
        holds -= 1
        if holds == 0 && armDeferred { arm() }
    }

    private func waitForWake() async {
        if stopped { return }
        await withCheckedContinuation { wakeWaiters.append($0) }
    }

    func idleWatchdog(_ maxIdle: TimeInterval) async {
        while !stopped && !Task.isCancelled {
            guard let at = turnEndedAt else {
                await waitForWake()
                continue
            }
            let remaining = maxIdle - (now() - at)
            if remaining <= 0 {
                sessionLog.info("session idle for \(Int(maxIdle.rounded()))s after its turn ended; stopping")
                stop()
                return
            }
            // Wait out the remaining grace, waking early if the clock changes or the runner stops.
            let timer = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                await self?.signal()
            }
            await waitForWake()
            timer.cancel()
        }
    }

    // MARK: Stream and reconcile

    func streamLoop() async {
        var backoff = runner.timings.streamBackoffStart
        while !stopped && !Task.isCancelled {
            do {
                // Open the stream before reconciling, so an event emitted between the list call and the attach is
                // delivered live instead of lost.
                let stream = try await runner.events.streamEvents(runner.sessionID, extraHeaders: runner.extraHeaders)
                await reconcile()
                for try await event in stream {
                    if stopped { return }
                    backoff = runner.timings.streamBackoffStart
                    noteEvent(event)
                    if historyRead { notePrimaryThread(event) }
                    switch event["type"]?.stringValue {
                    case "agent.tool_use", "agent.custom_tool_use":
                        let id = event["id"]?.stringValue ?? ""
                        if !seen.contains(id) {
                            seen.insert(id)
                            await routeToolEvent(event)
                        }
                    case "user.tool_result":
                        if let id = event["tool_use_id"]?.stringValue { answered.insert(id) }
                    case "user.custom_tool_result":
                        if let id = event["custom_tool_use_id"]?.stringValue { answered.insert(id) }
                    case "user.tool_confirmation":
                        await noteConfirmation(event)
                    case "session.status_terminated", "session.deleted":
                        sessionLog.info("session terminated")
                        stop()
                        return
                    default: break
                    }
                }
                if Task.isCancelled { return }
            } catch {
                if stopped || Task.isCancelled || error is CancellationError { return }
                if !isTransientError(error) {
                    // Not a network or API failure: it propagates to the consumer, as it does out of the task group.
                    failure = error
                    stop()
                    return
                }
                if isFatalStatusError(error) {
                    // No amount of backoff will fix a 401/403.
                    sessionLog.error("stream failed permanently error=\(error)")
                    stop()
                    return
                }
                sessionLog.warning("stream disconnected, reconnecting backoff=\(String(format: "%.1f", backoff))s error=\(error)")
            }
            try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
            backoff = min(backoff * 2, runner.timings.streamBackoffCap)
        }
    }

    /// Read the full history and enqueue every tool-call event still unanswered (`_reconcile`).
    private func reconcile() async {
        var pending: [JSONValue] = []
        var lastEndedTurn = false
        var listFailed = false
        do {
            let history = try await runner.events.listEvents(runner.sessionID, limit: 1000, extraHeaders: runner.extraHeaders)
            for try await event in history {
                notePrimaryThread(event)
                switch event["type"]?.stringValue {
                case "agent.tool_use", "agent.custom_tool_use":
                    seen.insert(event["id"]?.stringValue ?? "")
                    pending.append(event)
                case "user.tool_result":
                    if let id = event["tool_use_id"]?.stringValue { answered.insert(id) }
                case "user.custom_tool_result":
                    if let id = event["custom_tool_use_id"]?.stringValue { answered.insert(id) }
                case "user.tool_confirmation":
                    if let id = event["tool_use_id"]?.stringValue, !answered.contains(id) {
                        confirmations[id] = event["result"]?.stringValue ?? ""
                    }
                default: break
                }
                if event["type"] != "user.tool_confirmation" { lastEndedTurn = endsTurn(event) }
            }
        } catch {
            // Pagination may have failed partway through; dispatching `pending` now would risk re-running a tool
            // whose result was on a page never reached.
            sessionLog.warning("reconcile list failed; skipping pending enqueue error=\(error)")
            listFailed = true
        }
        historyRead = !listFailed
        if listFailed {
            for event in pending { seen.remove(event["id"]?.stringValue ?? "") }
            return
        }
        let unanswered = pending.filter { !answered.contains($0["id"]?.stringValue ?? "") }
        disarm()
        for event in unanswered { await routeToolEvent(event) }
        for held in awaitingConfirmation.values {
            let id = held["id"]?.stringValue ?? ""
            if let verdict = confirmations[id] { await applyVerdict(held, verdict) }
        }
        let outstanding = unanswered.filter { event in
            let id = event["id"]?.stringValue ?? ""
            return !answered.contains(id) && !awaitingConfirmation.contains(id)
                && !(confirmations[id] != nil && toolsByName[event["name"]?.stringValue ?? ""] != nil)
        }
        if lastEndedTurn && outstanding.isEmpty { arm() }
    }

    private func notePrimaryThread(_ event: JSONValue) {
        if primaryThreadID != nil { return }
        let threadStatus: Set<String> = [
            "session.thread_status_running", "session.thread_status_idle", "session.thread_status_rescheduled",
            "session.thread_status_terminated",
        ]
        if let type = event["type"]?.stringValue, threadStatus.contains(type),
           let thread = event["session_thread_id"]?.stringValue, !thread.isEmpty
        {
            primaryThreadID = thread
        }
    }

    /// Enqueue `event` for dispatch, honouring its evaluated permission. The gate fails closed: only an explicit
    /// `allow` verdict releases a gated call, and an unrecognised permission is held like `ask`.
    private func routeToolEvent(_ event: JSONValue) async {
        let id = event["id"]?.stringValue ?? ""
        let permission = event["evaluated_permission"].flatMap { $0.isNull ? nil : $0.stringValue }
        let verdict = confirmations[id]
        if permission == "deny" {
            await resolveDenied(event)
            return
        }
        guard let verdict else {
            if permission == nil || permission == "allow" {
                workContinuation.yield((event, nil))
            } else if !awaitingConfirmation.contains(id) {
                sessionLog.info(
                    "tool \(pythonStringRepr(event["name"]?.stringValue ?? "")) requires user confirmation; holding tool_use_id=\(id) until user.tool_confirmation")
                awaitingConfirmation[id] = event
                hold()
            }
            return
        }
        await applyVerdict(event, verdict)
    }

    private func noteConfirmation(_ event: JSONValue) async {
        guard let id = event["tool_use_id"]?.stringValue else { return }
        let verdict = event["result"]?.stringValue ?? ""
        confirmations[id] = verdict
        guard let held = awaitingConfirmation[id] else { return }
        await applyVerdict(held, verdict)
    }

    private func applyVerdict(_ event: JSONValue, _ verdict: String) async {
        let id = event["id"]?.stringValue ?? ""
        let wasHeld = awaitingConfirmation[id] != nil
        awaitingConfirmation[id] = nil
        if verdict == "allow" {
            sessionLog.info("tool call confirmed tool=\(event["name"]?.stringValue ?? "") tool_use_id=\(id)")
            if !wasHeld { hold() }
            if stopped {
                release()
                return
            }
            workContinuation.yield((event, "allow"))
        } else {
            if wasHeld { release() }
            await resolveDenied(event)
        }
    }

    private func resolveDenied(_ event: JSONValue) async {
        let id = event["id"]?.stringValue ?? ""
        answered.insert(id)
        sessionLog.info("tool call denied; not executing tool=\(event["name"]?.stringValue ?? "") tool_use_id=\(id)")
        results.yield(DispatchedToolCall(event: event, result: nil, toolUseID: id, name: event["name"]?.stringValue ?? "",
                                         isError: false, posted: false, confirmation: "deny"))
    }

    // MARK: Dispatch

    func dispatchLoop() async {
        for await (event, confirmation) in work {
            if !answered.contains(event["id"]?.stringValue ?? "") {
                await execute(event, confirmation)
            }
            if confirmation == "allow" { release() }
        }
    }

    private func execute(_ event: JSONValue, _ confirmation: String?) async {
        let id = event["id"]?.stringValue ?? ""
        let name = event["name"]?.stringValue ?? ""
        sessionLog.info("executing tool tool=\(name) tool_use_id=\(id)")
        var result: JSONValue?
        var isError = false
        var sent = false
        if let tool = toolsByName[name] {
            let resultEvent = await callTool(tool, event)
            result = resultEvent
            isError = resultEvent["is_error"] == true
            sent = await sendResult(resultEvent, toolUseID: id)
        } else {
            // A name this runner is not registered for belongs to the other client servicing the session: post no
            // result, do not mark it answered, and leave the id pending for its owner.
            sessionLog.info("tool \(pythonStringRepr(name)) not owned by this runner; leaving tool_use_id=\(id) pending for its owner")
            if confirmation == "allow" { disarm() }
        }
        results.yield(DispatchedToolCall(event: event, result: result, toolUseID: id, name: name, isError: isError,
                                         posted: sent, confirmation: confirmation))
    }

    /// Runs `tool` for `event` and builds the result event, turning a timeout or an error into an error result.
    private func callTool(_ tool: any BetaRunnableTool, _ event: JSONValue) async -> JSONValue {
        let name = event["name"]?.stringValue ?? ""
        let input = event["input"] ?? [:]
        let timeout = runner.timings.toolTimeout
        var content: JSONValue
        var isError = false
        do {
            content = try await withToolTimeout(timeout) { toolResultContent(try await tool.call(input)) }
        } catch is ToolTimedOut {
            content = .string("tool \(pythonStringRepr(name)) timed out")
            isError = true
        } catch let error as ToolError {
            content = toolErrorContent(error)
            isError = true
        } catch {
            sessionLog.exception("tool \(name) raised", error)
            content = toolErrorContent(error)
            isError = true
        }
        return buildResultEvent(event, toSessionContent(content), isError: isError)
    }

    /// Posts `result` back to the session, retrying transient failures with jittered exponential backoff until the
    /// send retry window elapses.
    private func sendResult(_ result: JSONValue, toolUseID: String) async -> Bool {
        let start = now()
        var lastError: Error?
        var attempt = 0
        while true {
            attempt += 1
            do {
                try await runner.events.sendEvents(runner.sessionID, events: [result], extraHeaders: runner.extraHeaders)
                answered.insert(toolUseID)
                return true
            } catch {
                lastError = error
                if !isTransientError(error) || isFatalStatusError(error) { break }
                let remaining = (runner.sendRetryWindow() ?? runner.timings.sendRetryWindow) - (now() - start)
                if remaining <= 0 { break }
                let delay = retryBackoff(attempt - 1, cap: runner.timings.sendBackoffCap)
                let wait = min(Double.random(in: (delay / 2)..<max(delay, delay / 2 + .ulpOfOne)), remaining)
                sessionLog.warning(
                    "tool result send failed; retrying tool_use_id=\(toolUseID) attempt=\(attempt) backoff=\(String(format: "%.1f", wait))s error=\(error)")
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
            }
        }
        sessionLog.error("failed to send tool result tool_use_id=\(toolUseID) attempts=\(attempt) error=\(lastError.map { "\($0)" } ?? "None")")
        return false
    }
}

struct ToolTimedOut: Error {}

/// Runs `body`, throwing `ToolTimedOut` once `seconds` pass. A tool that ignores cancellation keeps running
/// unobserved, as a timed-out sync tool's thread does upstream.
func withToolTimeout<T: Sendable>(_ seconds: TimeInterval, _ body: @escaping @Sendable () async throws -> T) async throws -> T {
    let box = TimeoutRace<T>()
    return try await withCheckedThrowingContinuation { continuation in
        box.set(continuation)
        let work = Task {
            do { box.resume(.success(try await body())) } catch { box.resume(.failure(error)) }
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
            if box.resume(.failure(ToolTimedOut())) { work.cancel() }
        }
    }
}

private final class TimeoutRace<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Error>?

    func set(_ c: CheckedContinuation<T, Error>) { lock.withLock { continuation = c } }

    @discardableResult
    func resume(_ result: Result<T, Error>) -> Bool {
        let c: CheckedContinuation<T, Error>? = lock.withLock {
            let c = continuation
            continuation = nil
            return c
        }
        c?.resume(with: result)
        return c != nil
    }
}
