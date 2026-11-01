// Port of `anthropic/lib/threads/_params.py` and `_thread_state.py`: the state of a message thread, the
// conversation a tool runner sends turn by turn. Only what the tool runners need is ported (the public
// `client.beta.messages.thread()` API is not).
//
// Request fields and messages are held as JSON objects, as Python holds them as dicts: what the runner compares
// (`same_message`) and edits (`without_cache_control`) is the request body itself.

import Foundation

/// The request options of one turn (`RequestOptions`): each one given replaces the earlier value as a whole.
public struct ToolRunnerRequestOptions: Sendable {
    public var extraHeaders: Headers?
    public var extraQuery: Query?
    public var extraBody: Body?
    public var timeout: Timeout?

    public init(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) {
        self.extraHeaders = extraHeaders
        self.extraQuery = extraQuery
        self.extraBody = extraBody
        self.timeout = timeout
    }

    /// `override_request_options`: `self` with every option `overrides` sets replaced.
    func overridden(by overrides: ToolRunnerRequestOptions) -> ToolRunnerRequestOptions {
        var o = self
        if let h = overrides.extraHeaders { o.extraHeaders = h }
        if let q = overrides.extraQuery { o.extraQuery = q }
        if let b = overrides.extraBody { o.extraBody = b }
        if let t = overrides.timeout { o.timeout = t }
        return o
    }
}

/// Per-turn overrides (`TurnOverrides`): request fields (as JSON) and request options.
struct TurnOverrides {
    var fields: [String: JSONValue] = [:]
    var options = ToolRunnerRequestOptions()
}

/// The `create()` fields a thread holds between turns: every field except `messages`, `thread` and `stream`.
let THREAD_FIELDS: Set<String> = [
    "max_tokens", "model", "cache_control", "compaction", "container", "context_management", "diagnostics",
    "fallback_credit_token", "fallbacks", "inference_geo", "mcp_servers", "metadata", "output_config", "service_tier",
    "speed", "stop_sequences", "system", "thinking", "tool_choice", "betas", "user_profile_id", "workspace_id", "tools",
]

/// Request fields the server takes from the thread on a `continue` and rejects if the request repeats them.
let CREATE_ONLY_FIELDS = ["system", "tools"]

let MESSAGE_THREADS_BETA = "message-threads-2026-08-12"

/// `override_fields`: `params` with every thread field `overrides` sets replaced.
func overrideFields(_ params: [String: JSONValue], _ overrides: [String: JSONValue]) -> [String: JSONValue] {
    var out = params
    for (k, v) in overrides where THREAD_FIELDS.contains(k) { out[k] = v }
    return out
}

/// A message given to a thread: a request param, or a reply the thread received.
enum ThreadMessage {
    case param(JSONValue)
    case reply(BetaMessage)

    var param: JSONValue {
        switch self {
        case .param(let p): return p
        case .reply(let m): return messageParam(of: m)
        }
    }
}

/// `{"role": message.role, "content": message.content}` as the request sends it (`to_param()`).
func messageParam(of message: BetaMessage) -> JSONValue {
    ["role": .string(message.role), "content": (try? JSONValue.from(message.content)) ?? .array([])]
}

/// A message of the history: one the caller gave, or a reply the thread received from the server.
final class ThreadEntry {
    let param: JSONValue
    let message: BetaMessage?
    let partial: Bool

    init(given param: JSONValue) {
        self.param = param
        self.message = nil
        self.partial = false
    }

    init(reply message: BetaMessage, partial: Bool = false) {
        self.param = messageParam(of: message)
        self.message = message
        self.partial = partial
    }

    var isReply: Bool { message != nil }
}

/// Where the next turn stands on a server-side thread.
enum ThreadPosition {
    /// Turns carry no `thread` field because the conversation was never a thread.
    case off
    /// Turns carry no `thread` field because the thread stopped threading.
    case unthreaded
    /// The next turn is a `create` with the whole history.
    case new(replacesLostThread: Bool)
    /// A `create` went out with `createdWith`, of which `givenForTheTurn` are not the thread's own.
    case created(createdWith: [String: JSONValue], givenForTheTurn: [String: JSONValue], replacesLostThread: Bool)
    /// The server holds the thread up to the reply `previousMessageID`.
    case continuing(previousMessageID: String, createdWith: [String: JSONValue], replacesLostThread: Bool)
}

/// A turn in flight: the entries staged by the call that started it, and the history edits to apply once it ends.
final class ThreadTurn {
    let startedWith: [ThreadEntry]
    var deferredMessages: [ThreadMessage] = []
    var replacementHistory: [JSONValue]?

    init(startedWith: [ThreadEntry]) { self.startedWith = startedWith }
}

/// The arguments of one turn's `create()` call (`CreateArguments`).
struct CreateArguments {
    var fields: [String: JSONValue]
    var options: ToolRunnerRequestOptions
}

private let threadLog = ToolLogger(name: "anthropic.lib.threads._thread_state")

/// A thread's local view of the conversation (`ThreadState`): the full history, which part of it the server holds
/// and which reply the next turn continues from, the request fields for the next turn, and the turn in flight.
/// Sends nothing itself.
final class ThreadState: @unchecked Sendable {
    var options: ToolRunnerRequestOptions
    private let helperHeaders: Headers
    var unsupportedRequestBehavior: String
    /// The tools as given, function tools included; `fields["tools"]` holds their request definitions.
    private(set) var tools: [any BetaToolLike]?
    var runnableTools = OrderedDict<any BetaRunnableTool>()
    var fields: [String: JSONValue] = [:]

    private var stored: [ThreadEntry] = []
    private var staged: [ThreadEntry] = []
    private var thread: ThreadPosition
    private var turn: ThreadTurn?

    init(fields: [String: JSONValue], messages: [JSONValue], tools: [any BetaToolLike]?, options: ToolRunnerRequestOptions,
         threading: Bool, unsupportedRequestBehavior: String) throws
    {
        self.options = options
        self.helperHeaders = threading ? [STAINLESS_HELPER_HEADER: "message-thread"] : [:]
        self.unsupportedRequestBehavior = unsupportedRequestBehavior
        self.thread = threading ? .new(replacesLostThread: false) : .off
        try setParams(fields: fields, messages: messages, tools: tools)
    }

    private init(copying other: ThreadState) {
        options = other.options
        helperHeaders = other.helperHeaders
        unsupportedRequestBehavior = other.unsupportedRequestBehavior
        tools = other.tools
        runnableTools = other.runnableTools
        fields = other.fields
        stored = other.stored
        staged = other.staged
        thread = other.thread
        turn = nil
    }

    /// Whether turns send a `thread` field at all.
    var threading: Bool {
        switch thread {
        case .off, .unthreaded: return false
        default: return true
        }
    }

    var isOff: Bool { if case .off = thread { return true } else { return false } }

    /// The `id` of the stored reply the next turn continues from.
    var previousMessageID: String? {
        if case .continuing(let id, _, _) = thread { return id }
        return nil
    }

    /// Every message the server holds plus those staged, with any edits deferred by a turn in flight applied.
    var messages: [JSONValue] {
        var messages: [JSONValue]
        if let replacement = turn?.replacementHistory {
            messages = replacement
        } else {
            messages = (stored + staged).map(\.param)
        }
        if let turn { messages += turn.deferredMessages.map(\.param) }
        return messages
    }

    /// Stage messages for the next turn, skipping the reply just recorded and deferring while a turn is in flight.
    func append(_ messages: [ThreadMessage]) {
        if let turn {
            turn.deferredMessages += messages
            return
        }
        for message in messages where !repeatsLastReply(message) {
            staged.append(ThreadEntry(given: message.param))
        }
    }

    private func repeatsLastReply(_ message: ThreadMessage) -> Bool {
        switch message {
        case .reply(let m):
            return lastReply.map { $0.id == m.id } ?? false
        case .param(let p):
            let entries = staged.isEmpty ? stored : staged
            guard let last = entries.last, last.isReply else { return false }
            return sameMessage(p, last.param)
        }
    }

    private var lastReply: BetaMessage? {
        for entries in [staged, stored] {
            for entry in entries.reversed() { if let m = entry.message { return m } }
        }
        return nil
    }

    var hasStagedMessages: Bool { !staged.isEmpty }

    /// Apply the given request fields, tools and request options to all later turns.
    func update(_ overrides: TurnOverrides, tools: [any BetaToolLike]? = nil) throws {
        fields = overrideFields(fields, overrides.fields)
        if let tools {
            self.tools = tools
            try readTools()
        }
        options = options.overridden(by: overrides.options)
        if case .created(let createdWith, var given, let replaces) = thread {
            for field in CREATE_ONLY_FIELDS where overrides.fields[field] != nil || (field == "tools" && tools != nil) {
                given.removeValue(forKey: field)
            }
            thread = .created(createdWith: createdWith, givenForTheTurn: given, replacesLostThread: replaces)
        }
    }

    private func readTools() throws {
        guard let tools else { return }
        var registry = OrderedDict<any BetaRunnableTool>()
        var definitions: [JSONValue] = []
        for tool in tools {
            if let runnable = tool as? any BetaRunnableTool { registry[runnable.name] = runnable }
            definitions.append(try tool.toToolParam())
        }
        runnableTools = registry
        fields["tools"] = .array(definitions)
    }

    /// A copy with the same history, request fields, tools and options that continues from no stored reply.
    func fork() -> ThreadState {
        let fork = ThreadState(copying: self)
        fork.thread = threading ? .new(replacesLostThread: false) : thread
        if let turn {
            if let replacement = turn.replacementHistory {
                fork.stored = []
                fork.staged = replacement.map { ThreadEntry(given: $0) }
            }
            fork.append(turn.deferredMessages)
        }
        return fork
    }

    /// Replace the request fields and tools with these, then `setMessages()`.
    func setParams(fields newFields: [String: JSONValue], messages: [JSONValue], tools: [any BetaToolLike]?) throws {
        fields = newFields.filter { THREAD_FIELDS.contains($0.key) && $0.key != "tools" }
        adoptContainer(lastReply)
        self.tools = nil
        if case .created(let createdWith, _, let replaces) = thread {
            thread = .created(createdWith: createdWith, givenForTheTurn: [:], replacesLostThread: replaces)
        }
        try update(TurnOverrides(), tools: tools)
        setMessages(messages)
    }

    /// Take the history from `messages`: additions to the current history are staged, and any other list replaces
    /// it and starts a new thread.
    func setMessages(_ messages: [JSONValue]) {
        if let turn {
            let sent = (stored + staged).map(\.param)
            if sameMessages(Array(messages.prefix(sent.count)), sent) {
                turn.replacementHistory = nil
                turn.deferredMessages = messages.dropFirst(sent.count).map { .param($0) }
            } else {
                turn.replacementHistory = messages
                turn.deferredMessages = []
            }
            return
        }
        let oldEntries = stored + staged
        let storedParams = stored.map(\.param)
        if !sameMessages(Array(messages.prefix(storedParams.count)), storedParams) {
            stored = []
            if threading { thread = .new(replacesLostThread: false) }
        }
        staged = []
        let replies = oldEntries.filter(\.isReply)
        for message in messages.dropFirst(stored.count) {
            if repeatsLastReply(.param(message)) { continue }
            let recorded = replies.reversed().first { sameMessage(message, $0.param) }
            staged.append(recorded ?? ThreadEntry(given: message))
        }
    }

    /// The thread as the arguments of one call for the whole conversation (`params`).
    var params: (fields: [String: JSONValue], messages: [JSONValue], tools: [any BetaToolLike]?) {
        var f = fields
        if turn != nil, case .created(_, let given, _) = thread {
            for (k, v) in given { f[k] = v }
        }
        return (f, messages, tools)
    }

    /// Stage `messages` and start the turn that sends them.
    func startTurn(_ messages: [ThreadMessage]) throws {
        if turn != nil {
            throw AnthropicError("Another `send()`, `parse()` or `stream()` is already in progress on this thread")
        }
        let stagedBefore = staged.count
        append(messages)
        turn = ThreadTurn(startedWith: Array(staged[stagedBefore...]))
        retryPartialTurn()
    }

    /// Mark the turn in flight finished and apply the history edits deferred during it.
    func endTurn() {
        guard let turn else { return }
        self.turn = nil
        staged = staged.filter { entry in !turn.startedWith.contains { $0 === entry } }
        if let replacement = turn.replacementHistory { setMessages(replacement) }
        append(turn.deferredMessages)
    }

    /// Whether the turn should be sent again because `error` is a thread rejection this state has adjusted for.
    func recoversFrom(_ error: APIStatusError) -> Bool {
        let continueUnthreaded = unsupportedRequestBehavior == "continue_unthreaded"
        let details = errorDetails(error)
        let code = details["error_code"]?.stringValue
        if let code, ["thread_not_found", "thread_already_continued", "thread_continue_in_flight"].contains(code),
           case .continuing(_, _, let replacesLost) = thread
        {
            if code == "thread_not_found" && replacesLost && continueUnthreaded {
                threadLog.info(
                    "The server lost the thread again right after a replay; continuing without a thread: previous_message_id=\(previousMessageID ?? "None")")
                stopThreading()
            } else {
                startNewThread(code)
            }
            return true
        }
        if code == "thread_unsupported_request" && threading && continueUnthreaded {
            let unsupported = details["unsupported"]?.arrayValue?.map { $0.stringValue ?? $0.description } ?? []
            threadLog.info(
                "The server cannot thread this request; continuing without a thread: unsupported=\(unsupported.joined(separator: ","))")
            stopThreading()
            return true
        }
        return false
    }

    private func startNewThread(_ reason: String) {
        threadLog.info(
            "Replaying the full message history under a new thread: reason=\(reason) previous_message_id=\(previousMessageID ?? "None")")
        thread = .new(replacesLostThread: reason == "thread_not_found")
    }

    /// Drop the `thread` field from this turn and every later one.
    func stopThreading() {
        if threading { thread = .unthreaded }
    }

    /// Record `message` as the turn's reply, for the next turn to continue from.
    func recordReply(_ message: BetaMessage) throws {
        if message.stopReason == .refusal && !isOff {
            if previousMessageID != nil { startNewThread("refusal") }
            return
        }
        storeTurn(ThreadEntry(reply: message))
        if case .created(_, let given, _) = thread {
            let givenTools = given["tools"]
            let tools: [any BetaToolLike]? = (givenTools == nil || givenTools == fields["tools"]) ? nil : givenTools?.arrayValue
            try update(TurnOverrides(fields: given), tools: tools)
        }
        switch thread {
        case .created(let createdWith, _, let replaces):
            thread = .continuing(previousMessageID: message.id, createdWith: createdWith, replacesLostThread: replaces)
        case .continuing(_, let createdWith, _):
            thread = .continuing(previousMessageID: message.id, createdWith: createdWith, replacesLostThread: false)
        default: break
        }
        if case .continuing = thread {
            let iterations = (try? JSONValue.from(message.usage))?["iterations"]?.arrayValue ?? []
            if iterations.contains(where: { $0["type"] == "fallback_message" }) { startNewThread("fallback_message") }
        }
        adoptContainer(message)
    }

    /// Continue in the container of `reply` on later turns, unless the thread already names one.
    private func adoptContainer(_ reply: BetaMessage?) {
        guard let container = reply?.container else { return }
        switch fields["container"] {
        case nil, .null?: fields["container"] = .string(container.id)
        case .object(var o)?:
            if o["id"].map({ $0.isNull || $0 == "" }) ?? true {
                o["id"] = .string(container.id)
                fields["container"] = .object(o)
            }
        default: break
        }
    }

    /// Record a turn whose stream ended after `message_start` and before `message_stop`.
    func recordPartialReply(_ snapshot: BetaMessage, completedBlocks: Int) throws {
        if snapshot.stopReason == .refusal && !isOff {
            try recordReply(snapshot)
            return
        }
        var content = Array(snapshot.content.prefix(completedBlocks))
        if completedBlocks < snapshot.content.count, case .text(let t) = snapshot.content[completedBlocks], !t.text.isEmpty {
            content.append(snapshot.content[completedBlocks])
        }
        if content.isEmpty {
            storeTurn(nil)
        } else {
            var partial = snapshot
            partial.content = content
            storeTurn(ThreadEntry(reply: partial, partial: true))
        }
        if previousMessageID != nil { startNewThread("stream_ended_before_message_stop") }
    }

    /// If nothing is staged and the history ends with a turn whose stream ended early, stage its messages again.
    private func retryPartialTurn() {
        guard staged.isEmpty, let tail = stored.last else { return }
        if tail.isReply {
            if !tail.partial { return }
            stored.removeLast()
        }
        let turnStart = answeredCount
        staged = Array(stored[turnStart...])
        stored.removeSubrange(turnStart...)
        threadLog.info(
            "Re-sending the turn whose reply ended before `message_stop`: partial_reply_id=\(tail.message?.id ?? "None")")
    }

    /// How many stored messages there are up to the last reply.
    private var answeredCount: Int {
        (stored.lastIndex { $0.isReply }).map { $0 + 1 } ?? 0
    }

    private func storeTurn(_ reply: ThreadEntry?) {
        stored += staged
        staged = []
        if let reply { stored.append(reply) }
    }

    /// Settle the `thread` field for this turn and build its `create()` arguments.
    func createArguments(_ overrides: TurnOverrides, stream: Bool) throws -> CreateArguments {
        var params = try turnParams(overrides)
        let threadParam = try threadForTurn(params, overrides)
        let resend = previousMessageID != nil ? [] : storedMessagesToSendAgain()
        params["messages"] = .array(resend + staged.map(\.param))
        let betas = params["betas"]?.arrayValue ?? []
        if threading && !betas.contains(.string(MESSAGE_THREADS_BETA)) {
            params["betas"] = .array(betas + [.string(MESSAGE_THREADS_BETA)])
        }
        if let threadParam {
            params["thread"] = threadParam
            if threadParam["type"] == "continue" {
                for field in CREATE_ONLY_FIELDS { params.removeValue(forKey: field) }
            }
        }
        return CreateArguments(fields: params, options: requestOptions(overrides, stream: stream))
    }

    private func storedMessagesToSendAgain() -> [JSONValue] {
        let messages = stored.map(\.param)
        if isOff { return messages }
        let answered = answeredCount
        return messages.prefix(answered).map(withoutCacheControl) + messages.dropFirst(answered)
    }

    /// Raise what the next turn with `overrides` would raise before it is sent.
    func checkNextTurn(_ overrides: TurnOverrides) throws {
        if case .continuing(_, let createdWith, _) = thread {
            try checkCreateOnlyFields(try turnParams(overrides), createdWith: createdWith)
        }
    }

    private func threadForTurn(_ params: [String: JSONValue], _ overrides: TurnOverrides) throws -> JSONValue? {
        switch thread {
        case .off, .unthreaded: return nil
        case .continuing(let id, let createdWith, _):
            try checkCreateOnlyFields(params, createdWith: createdWith)
            return ["type": "continue", "previous_message_id": .string(id)]
        case .new(let replaces), .created(_, _, let replaces):
            var createdWith: [String: JSONValue] = [:]
            for f in CREATE_ONLY_FIELDS { if let v = params[f] { createdWith[f] = v } }
            let given = createdWith.filter { overrides.fields[$0.key] != nil }
            thread = .created(createdWith: createdWith, givenForTheTurn: given, replacesLostThread: replaces)
            return ["type": "create"]
        }
    }

    private func checkCreateOnlyFields(_ params: [String: JSONValue], createdWith: [String: JSONValue]) throws {
        let changed = CREATE_ONLY_FIELDS.filter { params[$0] != createdWith[$0] }.map { "`\($0)`" }
        if changed.isEmpty { return }
        var message = "Cannot change \(changed.joined(separator: " and ")) on a thread: the server keeps the ones the thread was "
            + "created with. To change them, start a new thread from `thread.params`."
        if changed.contains("`tools`") {
            message += " To add or remove tools on this thread, send `tool_addition` or `tool_removal` blocks in a "
                + "`system` message."
        }
        throw AnthropicError(message)
    }

    private func turnParams(_ overrides: TurnOverrides) throws -> [String: JSONValue] {
        try readTools()
        return overrideFields(fields, overrides.fields)
    }

    private func requestOptions(_ overrides: TurnOverrides, stream: Bool) -> ToolRunnerRequestOptions {
        var o = options.overridden(by: overrides.options)
        var headers = o.extraHeaders ?? [:]
        if stream {
            headers = mergeHeaders(
                [STAINLESS_HELPER_METHOD_HEADER: "stream", STAINLESS_STREAM_HELPER_HEADER: "beta.messages"], headers)
        }
        if threading { headers = withThreadsBeta(headers) }
        o.extraHeaders = mergeHeaders(headers, helperHeaders)
        return o
    }
}


/// `headers` with the threads beta appended to a caller-set `anthropic-beta` header, which would otherwise replace
/// the one `create()` builds from `betas`.
private func withThreadsBeta(_ headers: Headers) -> Headers {
    let (built, _) = buildHeaderLayers([headers])
    guard let callerBetas = built["anthropic-beta"] else { return mergeHeaders(headers) }
    return mergeHeaders(headers, ["anthropic-beta": .value(appendHeaderValue(callerBetas, MESSAGE_THREADS_BETA))])
}

/// The `error.details` object of the response body.
private func errorDetails(_ error: APIStatusError) -> [String: JSONValue] {
    error.body?["error"]?["details"]?.objectValue ?? [:]
}

func sameMessages(_ a: [JSONValue], _ b: [JSONValue]) -> Bool {
    a.count == b.count && zip(a, b).allSatisfy { sameMessage($0, $1) }
}

/// Whether `a` and `b` are sent as the same message.
func sameMessage(_ a: JSONValue, _ b: JSONValue) -> Bool {
    a["role"] == b["role"] && a == b
}

let KEYS_THAT_HOLD_BLOCKS: Set<String> = ["content", "source", "tool", "definition", "tool_references"]

/// A copy of `value` without the `cache_control` of any block in it, however deep. Only the keys that hold blocks
/// are followed, so free-form data such as a tool's `input` stays as it is.
func withoutCacheControl(_ value: JSONValue) -> JSONValue {
    switch value {
    case .object(let o):
        var out: [String: JSONValue] = [:]
        for (k, v) in o where k != "cache_control" {
            out[k] = KEYS_THAT_HOLD_BLOCKS.contains(k) ? withoutCacheControl(v) : v
        }
        return .object(out)
    case .array(let a): return .array(a.map(withoutCacheControl))
    default: return value
    }
}
