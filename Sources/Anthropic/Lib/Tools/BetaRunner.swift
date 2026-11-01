// Port of `anthropic/lib/tools/_beta_runner.py` (`BetaAsyncToolRunner`): the agentic loop over
// `beta.messages.create`.
//
// Python drives the loop with an async generator; here an actor runs one step per `next()`: the request of a turn,
// then — when the caller asks for the next item — the handling of the reply (its tool calls, any compaction).

import Foundation

/// The params of a tool runner's requests, as the request body sends them (`ParseMessageCreateParamsBase`): the
/// request fields, `messages` and the `tools` definitions.
public typealias BetaToolRunnerParams = [String: JSONValue]

/// How the runner treats a finished assistant turn.
enum ToolRunnerStep: String, Sendable { case runTools = "run_tools", resume, stop }

/// Every stop reason maps to exactly one step (`_STOP_REASON_STEPS`).
let STOP_REASON_STEPS: [BetaStopReason: ToolRunnerStep] = [
    .toolUse: .runTools,
    .pauseTurn: .resume,
    // pause_after_compaction hands the turn back before the model answers; the next request continues it.
    .compaction: .resume,
    .endTurn: .stop,
    .stopSequence: .stop,
    .maxTokens: .stop,
    .modelContextWindowExceeded: .stop,
    .refusal: .stop,
]

func determineNextStep(_ stopReason: BetaStopReason?) -> ToolRunnerStep {
    if let stopReason, let step = STOP_REASON_STEPS[stopReason] { return step }
    // Absent and unknown (forward-compatible) values stop like any other finished turn.
    return .stop
}

let runnerLog = ToolLogger(name: "anthropic.lib.tools._beta_runner")

func rejectCompactionParam(_ params: [String: JSONValue]) throws {
    if let compaction = params["compaction"], !compaction.isNull {
        throw ValueError(
            "`compaction` cannot be set on a tool runner: every request in the loop would compact again. "
                + "Call `runner.compact_before_next_turn()` when the conversation should be compacted instead.")
    }
}

func rejectThreadParam(_ thread: JSONValue?) throws {
    guard let thread, !thread.isNull, thread != false else { return }
    throw ArgumentTypeError(
        "`thread` cannot be set in the params of a tool runner, got \(pythonRepr(thread)). The runner sets it for each request "
            + "itself. To run without a message thread, pass `thread=False` to `tool_runner()`.")
}

private func withoutFormat(_ outputConfig: JSONValue) -> JSONValue {
    guard case .object(var o) = outputConfig else { return outputConfig }
    o.removeValue(forKey: "format")
    return .object(o)
}

/// A compaction request returns only the compaction block, never a reply, so the API rejects the params that only
/// shape a reply. The runner's later requests keep them.
func withoutCompactionIncompatibleParams(_ params: [String: JSONValue]) -> [String: JSONValue] {
    var trimmed = params
    for name in ["context_management", "stop_sequences", "output_format"] { trimmed.removeValue(forKey: name) }
    if let type = params["tool_choice"]?["type"]?.stringValue, type == "any" || type == "tool" {
        trimmed.removeValue(forKey: "tool_choice")
    }
    if let outputConfig = params["output_config"], case .object(let o) = outputConfig, !o.isEmpty {
        trimmed["output_config"] = withoutFormat(outputConfig)
    }
    if case .array(let fallbacks)? = params["fallbacks"], !fallbacks.isEmpty {
        trimmed["fallbacks"] = .array(fallbacks.map { fallback in
            guard case .object(var f) = fallback, let oc = f["output_config"], case .object(let oco) = oc, !oco.isEmpty else {
                return fallback
            }
            f["output_config"] = withoutFormat(oc)
            return .object(f)
        })
    }
    return trimmed
}

/// The tool a name runs under where that differs from the thread's tools.
private enum ToolOverride {
    case tool(any BetaRunnableTool)
    case removed
}

/// How a runner sends each turn and what it hands out for it.
enum ToolRunnerRequestKind<Item: Sendable, Output: Sendable>: Sendable {
    /// `parse()`: the reply (`BetaAsyncToolRunner`).
    case message(@Sendable (ParsedBetaMessage<Output>) -> Item)
    /// `stream()`: the reply's stream (`BetaAsyncStreamingToolRunner`).
    case stream(@Sendable (BetaMessageStream<Output>) -> Item, runToolsEagerly: Bool)
}

/// One request of the loop: the reply, or the stream it arrives on (Python's `_last_message`).
final class ToolRunnerTurn<Output: Sendable>: @unchecked Sendable {
    let thread: MessageThread
    let reply: ParsedBetaMessage<Output>?
    let stream: BetaMessageStream<Output>?
    /// Whether the stream was recorded and the thread's turn ended, which happens once.
    var ended = false

    init(thread: MessageThread, reply: ParsedBetaMessage<Output>) {
        self.thread = thread
        self.reply = reply
        self.stream = nil
    }

    init(thread: MessageThread, stream: BetaMessageStream<Output>) {
        self.thread = thread
        self.reply = nil
        self.stream = stream
    }

    /// The reply; a stream is read to its end first.
    func finalMessage() async throws -> ParsedBetaMessage<Output> {
        if let reply { return reply }
        return try await stream!.getFinalMessage()
    }
}

/// Runs the tools the model calls until it stops asking for them (`BaseToolRunner`). It comes in three forms:
/// `BetaToolRunner` yields each `BetaMessage`, `BetaParsedToolRunner<Output>` each reply parsed into a structured
/// output, and `BetaStreamingToolRunner<Output>` each reply's `BetaMessageStream`. Make one with
/// `client.beta.messages.toolRunner(...)` or `client.beta.messages.streamingToolRunner(...)`.
///
/// ```swift
/// let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: [...], model: "claude-haiku-4-5", tools: [getWeather])
/// for try await message in runner {
///     print(message)
/// }
/// // or: let final = try await runner.untilDone()
/// ```
public actor BaseBetaToolRunner<Item: Sendable, Output: Sendable>: AsyncSequence {
    public typealias Element = Item

    let thread: MessageThread
    /// While a reply is handled, the history that `setMessagesParams()` and `appendMessages()` read and change: what
    /// the request sent, without the reply. `nil` at any other time.
    private var messages: [JSONValue]?
    /// Whether `messages` was reassigned since the request went out (Python's `messages is self._sent_messages`).
    private var messagesReplaced = false
    private var sentMessages: [JSONValue] = []
    /// Whether `appendMessages()` was called while the reply was handled: the caller then owns the turn's history.
    private var messagesModified = false
    /// Whether the thread itself was given messages while the last reply was handled.
    private var appendedToThread = false

    private let options: TurnOverrides
    private let kind: ToolRunnerRequestKind<Item, Output>
    /// Parses the replies of a thread that has an output format.
    private let parser: OutputParser<Output>?
    private var toolOverrides = OrderedDict<ToolOverride>()
    private var toolsets = OrderedDict<BetaRunnableToolset>()
    private let helperHeaders: Headers
    private var cachedToolCallResponse: JSONValue?
    private let maxIterations: Int?
    private var iterationCount = 0
    private var closed = false

    private var pendingCompaction: JSONValue?
    private var messagesBeingCompacted: [JSONValue]?
    private var pendingToolChanges: [JSONValue] = []
    /// The tool calls of the streamed reply being handled. `nil` without `runToolsEagerly`.
    private var eagerToolCalls: EagerToolCalls?
    /// Whether a tool is running inside a read of a streamed reply. Closing the runner then only stops the loop at
    /// its next step, as closing the reply would close it under that read.
    private var runningEagerTool = false

    private var lastTurn: ToolRunnerTurn<Output>?
    private var pending: PendingStep?
    private var finished = false
    private var loopStopReason: BetaStopReason?

    /// What the loop does when it is next asked for an item.
    private enum PendingStep {
        /// Handle the reply of a turn that was handed out.
        case turn(ToolRunnerTurn<Output>)
        /// Register the response of a compaction request that was handed out.
        case compaction(ToolRunnerTurn<Output>, compactedCount: Int, previous: ToolRunnerTurn<Output>?, thenStop: Bool)
    }

    init(thread: MessageThread, options: ToolRunnerRequestOptions, tools: [any BetaToolLike] = [], maxIterations: Int?,
         kind: ToolRunnerRequestKind<Item, Output>, parser: OutputParser<Output>?) throws
    {
        self.thread = thread
        self.options = TurnOverrides(options: options)
        self.maxIterations = maxIterations
        self.kind = kind
        self.parser = parser
        let (byName, byFamily) = indexRunnables(tools)
        for (name, tool) in byName.items { toolOverrides[name] = .tool(tool) }
        toolsets = byFamily

        var helpers: [String] = []
        let taggedTools: [any BetaToolLike] = (thread.state.tools ?? []) + tools
        for tool in taggedTools {
            if let tag = tool.helperTag, !helpers.contains(tag) { helpers.append(tag) }
        }
        var headers: Headers = [STAINLESS_HELPER_HEADER: "BetaToolRunner"]
        if !helpers.isEmpty { headers = mergeHeaders(headers, [STAINLESS_HELPER_HEADER: .value(helpers.joined(separator: ", "))]) }
        helperHeaders = headers
        try rejectCompactionParam(thread.state.params.fields)
    }

    // MARK: - Iteration

    public nonisolated func makeAsyncIterator() -> Iterator { Iterator(runner: self) }

    public struct Iterator: AsyncIteratorProtocol {
        let runner: BaseBetaToolRunner
        public mutating func next() async throws -> Item? { try await runner.next() }
    }

    /// The next item, or `nil` once the loop is done.
    public func next() async throws -> Item? {
        do {
            while true {
                if closed { finished = true }
                if let step = pending {
                    pending = nil
                    if closed {
                        abandon(step)
                        return nil
                    }
                    if let item = try await resume(step) { return item }
                    continue
                }
                if finished { return nil }
                if let item = try await top() { return item }
            }
        } catch {
            finished = true
            pending = nil
            throw error
        }
    }

    /// Consumes the loop and returns the last message (`until_done()`).
    func untilDoneParsed() async throws -> ParsedBetaMessage<Output> {
        while try await next() != nil {}
        guard let lastTurn else { throw AnthropicError("The tool runner made no request") }
        return try await lastTurn.finalMessage()
    }

    /// Stop the runner early. Iterating a closed runner yields nothing; closing a runner that is done has no
    /// effect. A stream the runner handed out is closed with it. A loop closed from inside one of its tools stops at
    /// its next step.
    public func close() {
        closed = true
        // A tool that runs while the application reads a reply is inside that read, so the reply stays open.
        guard !runningEagerTool, let step = pending else { return }
        pending = nil
        finished = true
        abandon(step)
    }

    /// Close the request of a step that is not resumed.
    private func abandon(_ step: PendingStep) {
        switch step {
        case .turn(let turn):
            try? closeTurn(turn)
        case .compaction(let turn, _, _, _):
            messagesBeingCompacted = nil
            try? closeTurn(turn)
        }
    }

    /// The top of the loop: the next request, or `nil` once the loop stops.
    private func top() async throws -> Item? {
        if shouldStop() {
            finished = true
            return nil
        }
        sendPendingToolChanges(hold: loopStopReason == .pauseTurn)
        // The API can't compact a conversation that ends mid-turn, so a paused turn is resumed first.
        let turnPaused = determineNextStep(loopStopReason) == .resume
        if !turnPaused, let compaction = pendingCompaction {
            return try await startCompaction(compaction, thenStop: false)
        }
        sentMessages = thread.messages
        messages = sentMessages
        messagesReplaced = false
        let turn = try await handleRequest(thread)
        lastTurn = turn
        pending = .turn(turn)
        return item(of: turn)
    }

    /// The loop body after a turn was handed out.
    private func resume(_ step: PendingStep) async throws -> Item? {
        switch step {
        case .turn(let turn):
            let message = try await settle(turn).message
            loopStopReason = message.stopReason
            let nextStep = determineNextStep(message.stopReason)
            if nextStep != .stop {
                // No tool runs for a turn the thread refuses to send.
                try thread.state.checkNextTurn(options)
            }
            try handOverMessages(message)
            iterationCount += 1

            if nextStep == .stop {
                runnerLog.debug("Turn ended with stop_reason \(message.stopReason?.rawValue ?? "None"), exiting from tool runner loop.")
                return try await compactAfterFinalTurn(message)
            }
            if nextStep == .runTools {
                let response = try await generateToolCallResponseJSON()
                if response == nil && !appendedToThread {
                    runnerLog.debug("Tool call was not requested, exiting from tool runner loop.")
                    return try await compactAfterFinalTurn(message)
                }
                if let response, !messagesModified { appendToolResults(response) }
            }
            messagesModified = false
            cachedToolCallResponse = nil
            return nil

        case .compaction(let turn, let compactedCount, let previous, let thenStop):
            let message: BetaMessage
            do {
                message = try await settle(turn).message
            } catch {
                messagesBeingCompacted = nil
                throw error
            }
            messagesBeingCompacted = nil
            if !registerCompactionResponse(turn.thread, message, compactedCount) {
                // `untilDone()` still returns the turn the run ended on.
                lastTurn = previous
            }
            if thenStop { finished = true }
            return nil
        }
    }

    /// The reply of `turn`, after which its request is closed (leaving Python's `async with self._handle_request()`).
    private func settle(_ turn: ToolRunnerTurn<Output>) async throws -> ParsedBetaMessage<Output> {
        let message: ParsedBetaMessage<Output>
        do {
            message = try await turn.finalMessage()
        } catch {
            try? closeTurn(turn)
            throw error
        }
        try closeTurn(turn)
        return message
    }

    private func compactAfterFinalTurn(_ message: BetaMessage) async throws -> Item? {
        if let compaction = prepareCompactionAfterFinalTurn(message) {
            return try await startCompaction(compaction, thenStop: true)
        }
        finished = true
        return nil
    }

    private func startCompaction(_ compaction: JSONValue, thenStop: Bool) async throws -> Item {
        let previous = lastTurn
        let fork = try takeCompactionThread(compaction)
        let compactedCount = thread.messages.count
        let turn: ToolRunnerTurn<Output>
        do {
            turn = try await handleRequest(fork)
        } catch {
            messagesBeingCompacted = nil
            throw error
        }
        lastTurn = turn
        pending = .compaction(turn, compactedCount: compactedCount, previous: previous, thenStop: thenStop)
        return item(of: turn)
    }

    private func item(of turn: ToolRunnerTurn<Output>) -> Item {
        switch kind {
        case .message(let make): return make(turn.reply!)
        case .stream(let make, _): return make(turn.stream!)
        }
    }

    /// Send a turn on `thread` (`_handle_request`): parsed, or as a stream whose end ends the turn.
    private func handleRequest(_ thread: MessageThread) async throws -> ToolRunnerTurn<Output> {
        let parser = thread.state.outputFormat == nil ? nil : self.parser
        switch kind {
        case .message:
            let reply = try await thread.send(overrides: turnOptions(thread))
            return ToolRunnerTurn(thread: thread, reply: try parseBetaResponse(reply, parser: parser))
        case .stream(_, let runToolsEagerly):
            let raw = try await thread.openStream(overrides: turnOptions(thread))
            let stream = BetaMessageStream(rawStream: raw, parser: parser)
            let turn = ToolRunnerTurn(thread: thread, stream: stream)
            var hooks = BetaMessageStreamHooks()
            hooks.didEnd = { [weak self] in try await self?.closeTurn(turn, closingStream: false) }
            if runToolsEagerly {
                let calls = EagerToolCalls()
                eagerToolCalls = calls
                hooks.willYield = { [weak self] event in try await self?.runToolsWhileStreaming(event, calls) }
            }
            stream.hooks = hooks
            return turn
        }
    }

    /// Record a streamed turn and free its thread, unless the turn has ended already: the whole reply if the stream
    /// reached `message_stop`, the partial reply and a new thread if it ended after `message_start`, and nothing if
    /// it ended before that (`_end_turn`). A turn that is not streamed ended when its reply arrived.
    private func closeTurn(_ turn: ToolRunnerTurn<Output>, closingStream: Bool = true) throws {
        guard let stream = turn.stream else { return }
        if closingStream { stream.close() }
        if turn.ended { return }
        turn.ended = true
        let state = turn.thread.state
        defer { state.endTurn() }
        if let snapshot = stream.currentMessageSnapshot?.message {
            if stream.messageComplete {
                try state.recordReply(snapshot)
            } else {
                try state.recordPartialReply(snapshot, completedBlocks: stream.completedBlocks)
            }
        }
    }

    /// The runner's request options for a turn on `thread`; the runner's helper tags go on top of the headers.
    private func turnOptions(_ thread: MessageThread) -> TurnOverrides {
        let headers = options.options.extraHeaders ?? thread.state.options.extraHeaders ?? [:]
        var o = options
        o.options.extraHeaders = mergeHeaders(helperHeaders, headers)
        return o
    }

    private func shouldStop() -> Bool {
        if closed { return true }
        if let maxIterations, iterationCount >= maxIterations { return true }
        return false
    }

    // MARK: - Params and history

    /// The thread's params that a request takes: the request fields, `tools` as the definitions sent, and the whole
    /// history. The reply being handled is not part of it.
    public var params: BetaToolRunnerParams { paramsSnapshot() }

    private func paramsSnapshot() -> BetaToolRunnerParams {
        var params = thread.state.params.fields
        params["messages"] = .array(messages ?? thread.messages)
        return params
    }

    /// Update the params of the next request (`set_messages_params`). This invalidates any cached tool response.
    ///
    /// The new params replace the old ones, so a field they leave out is no longer sent, except `betas`,
    /// `user_profile_id` and `workspace_id`. A function tool or toolset taken out of `tools` is no longer run, and a
    /// function tool added to them is never run: use `addTools()` and `removeTools()`.
    public func setMessagesParams(_ transform: (BetaToolRunnerParams) throws -> BetaToolRunnerParams) throws {
        let current = paramsSnapshot()
        var params = try transform(current)
        for key in ["betas", "user_profile_id", "workspace_id"] where params[key] == nil {
            if let v = current[key] { params[key] = v }
        }
        try rejectCompactionParam(params)
        try rejectThreadParam(params["thread"])
        var newMessages = params["messages"]?.arrayValue ?? []
        if messagesBeingCompacted != nil && newMessages != thread.messages {
            throw ValueError(
                "Message params can't be changed while the conversation is being compacted, because the compaction "
                    + "response replaces them. Make the change on the next iteration.")
        }
        if pendingCompaction != nil || messagesBeingCompacted != nil { try checkCanCompact(params) }
        if messages != nil {
            messages = newMessages
            messagesReplaced = true
            newMessages = thread.messages
        }
        var tools: [any BetaToolLike]?
        if let given = params["tools"] {
            if given == current["tools"], let own = thread.state.tools {
                // Given back as handed out, so the thread keeps its own.
                tools = own
            } else {
                tools = (given.arrayValue ?? []).map { $0 as any BetaToolLike }
            }
        }
        let runnable = runnableTools()
        let families = toolsetsByFamily()
        let declared = declaredTools()
        params.removeValue(forKey: "messages")
        params.removeValue(forKey: "tools")
        params.removeValue(forKey: "thread")
        try thread.state.setParams(fields: params, messages: newMessages, tools: tools)
        let withdrawn = paramsSnapshot()["tools"] != nil ? declared.subtracting(declaredTools()) : []

        var overrides = OrderedDict<ToolOverride>()
        for name in thread.state.runnableTools.keys { overrides[name] = .removed }
        for (name, o) in toolOverrides.items { overrides[name] = o }
        for (name, tool) in runnable.items { overrides[name] = .tool(tool) }
        for name in withdrawn { overrides[name] = .removed }
        toolOverrides = overrides
        var kept = OrderedDict<BetaRunnableToolset>()
        for (family, toolset) in families.items where !withdrawn.contains(family) { kept[family] = toolset }
        toolsets = kept
    }

    /// Replace the params of the next request (`set_messages_params(params)`).
    public func setMessagesParams(_ params: BetaToolRunnerParams) throws {
        try setMessagesParams { _ in params }
    }

    /// Add messages to the conversation history (`append_messages`). This invalidates the cached tool response.
    public func appendMessages(_ messages: BetaMessageParam...) throws {
        try appendJSONMessages(messages.map { .param(try JSONValue.from($0)) })
    }

    /// Add assistant replies to the conversation history.
    public func appendMessages(_ messages: BetaMessage...) throws {
        try appendJSONMessages(messages.map { .reply($0) })
    }

    /// Add parsed assistant replies to the conversation history.
    public func appendMessages(_ messages: ParsedBetaMessage<Output>...) throws {
        try appendJSONMessages(messages.map { .reply($0.message) })
    }

    /// Add messages written as JSON to the conversation history.
    public func appendMessages(json messages: JSONValue...) throws {
        try appendJSONMessages(messages.map { .param($0) })
    }

    private func appendJSONMessages(_ new: [ThreadMessage]) throws {
        if messagesBeingCompacted != nil {
            throw ValueError(
                "Message params can't be changed while the conversation is being compacted, because the compaction "
                    + "response replaces them. Make the change on the next iteration.")
        }
        if messages == nil {
            thread.state.append(new)
        } else {
            messages! += new.map(\.param)
            messagesReplaced = true
            messagesModified = true
        }
        cachedToolCallResponse = nil
    }

    /// Compact the conversation before the model's next turn (`compact_before_next_turn`).
    ///
    /// This only schedules the compaction: once the current turn has finished, including any tool calls, the runner
    /// requests a summary and replaces the history with the compaction response, which is yielded like any other
    /// message (`stopReason == .compaction`). Requires the `compact-2026-09-04` beta.
    ///
    /// - Parameter compaction: The compaction config to send. Defaults to `{"type": "summarize"}`.
    public func compactBeforeNextTurn(_ compaction: BetaCompactionConfigParam? = nil) throws {
        if messagesBeingCompacted != nil { return }
        try checkCanCompact(paramsSnapshot())
        pendingCompaction = try compaction.map { try JSONValue.from($0) } ?? ["type": "summarize"]
    }

    private func checkCanCompact(_ params: [String: JSONValue]) throws {
        let edits = params["context_management"]?["edits"]?.arrayValue ?? []
        if edits.contains(where: { $0["type"]?.stringValue?.hasPrefix("compact_") ?? false }) {
            throw ValueError(
                "`compact_before_next_turn()` can't be used while `context_management` has a compaction edit, "
                    + "because the API doesn't accept a compaction block together with one. Remove the edit first.")
        }
    }

    private func takeCompactionThread(_ compaction: JSONValue) throws -> MessageThread {
        try checkCanCompact(paramsSnapshot())
        let fork = thread.fork()
        try fork.state.update(TurnOverrides(fields: ["compaction": compaction]))
        fork.state.fields = withoutCompactionIncompatibleParams(fork.state.fields)
        // The output format is added to `output_config` only when a turn is sent, so the fork drops it separately.
        fork.state.outputFormat = nil
        pendingCompaction = nil
        messagesBeingCompacted = thread.messages
        return fork
    }

    private func prepareCompactionAfterFinalTurn(_ message: BetaMessage) -> JSONValue? {
        let compaction = pendingCompaction
        if compaction != nil && !messagesModified && !appendedToThread
            && message.content.contains(where: { if case .toolUse = $0 { return true } else { return false } })
        {
            runnerLog.warning(
                "The pending compaction was skipped because the last turn (stop_reason=\(pythonStringRepr(message.stopReason?.rawValue ?? "None"))) "
                    + "ended with tool calls whose results were not sent. Call `compact_before_next_turn()` again if you continue the "
                    + "conversation.")
            pendingCompaction = nil
            return nil
        }
        return compaction
    }

    private func registerCompactionResponse(_ fork: MessageThread, _ message: BetaMessage, _ compactedCount: Int) -> Bool {
        if !fork.state.threading {
            // The API could not thread the compaction request, and would reject the next request as well.
            thread.state.stopThreading()
        }
        let hasSummary = message.content.contains {
            if case .compaction(let c) = $0 { return !(c.content ?? "").isEmpty }
            return false
        }
        if !hasSummary {
            runnerLog.warning("Compaction produced no summary; keeping the conversation as it is.")
            return false
        }
        let available = availableNames()
        for name in runnableTools().keys where !available.contains(name) { toolOverrides[name] = .removed }
        let response = messageParam(of: message)
        let appended = thread.messages.dropFirst(compactedCount).filter { !sameMessage($0, response) }
        thread.state.setMessages([response] + appended)
        return true
    }

    /// Give the thread the history as the loop body left it (`_hand_over_messages`).
    private func handOverMessages(_ reply: BetaMessage) throws {
        appendedToThread = thread.state.hasStagedMessages
        let handled = messages
        messages = nil
        guard var history = handled, messagesReplaced else { return }
        let replyParam = messageParam(of: reply)
        if !messagesModified { history.append(replyParam) }
        let added = thread.messages.dropFirst(sentMessages.count).filter { !sameMessage($0, replyParam) }
        thread.state.setMessages(history + added)
    }

    /// Add `results` right after the reply, ahead of messages added to the thread while it was handled.
    private func appendToolResults(_ results: JSONValue) {
        var all = thread.messages
        let index = (all.lastIndex { $0["role"] == "assistant" } ?? (all.count - 1)) + 1
        all.insert(results, at: index)
        thread.state.setMessages(all)
    }

    // MARK: - Tools

    /// Give the model more tools without changing the `tools` param, which would miss the prompt cache
    /// (`add_tools`).
    ///
    /// The definitions are sent in `tool_addition` blocks with the next request. A function tool is run straight
    /// away, in place of any tool of the same name. A raw definition is for server tools: the runner never runs it,
    /// and it stops running a function tool of the same name. Requires the `inline-tools-2026-09-15` beta.
    public func addTools(_ tools: any BetaToolLike...) throws {
        try addTools(tools)
    }

    public func addTools(_ tools: [any BetaToolLike]) throws {
        let families = toolsetsByFamily()
        for tool in tools {
            if let toolset = tool as? BetaRunnableToolset { throw ToolsetsFixedError(.add, toolset.toolsetName) }
            var name: String?
            if isRawDefinition(tool) {
                let definition = try tool.toToolParam()
                let family = toolFamily(definition)
                if families.contains(family) { throw ToolsetsFixedError(.replace, family) }
                name = definition["name"]?.stringValue
            } else if let runnable = tool as? any BetaRunnableTool {
                name = runnable.name
            }
            if let name, families.contains(name) {
                throw ToolsetContractError(
                    "add_tools() can't add a tool named '\(quotedName(name))': the runner's \(quotedName(name)) "
                        + "toolset has that name; give the tool another name")
            }
        }
        for tool in tools {
            let definition = try tool.toToolParam()
            if let runnable = tool as? any BetaRunnableTool {
                toolOverrides[runnable.name] = .tool(runnable)
            } else if let name = definition["name"]?.stringValue {
                toolOverrides[name] = .removed
            }
            pendingToolChanges.append(["type": "tool_addition", "tool": ["type": "tool_definition", "definition": definition]])
        }
    }

    /// Take tools away from the model without changing the `tools` param (`remove_tools`). The tools stop being run
    /// at once, and the model is told in `tool_removal` blocks with the next request.
    public func removeTools(_ names: String...) throws {
        try removeTools(names: names)
    }

    public func removeTools(_ tools: any BetaToolLike...) throws {
        let families = toolsetsByFamily()
        var names: [String] = []
        for tool in tools {
            if let toolset = tool as? BetaRunnableToolset { throw ToolsetsFixedError(.remove, toolset.toolsetName) }
            if let runnable = tool as? any BetaRunnableTool {
                names.append(runnable.name)
            } else if let name = try tool.toToolParam()["name"]?.stringValue {
                names.append(name)
            }
        }
        for name in names where families.contains(name) { throw ToolsetsFixedError(.remove, name) }
        try removeTools(names: names)
    }

    private func removeTools(names: [String]) throws {
        let families = toolsetsByFamily()
        for name in names where families.contains(name) { throw ToolsetsFixedError(.remove, name) }
        for name in names {
            toolOverrides[name] = .removed
            pendingToolChanges.append(["type": "tool_removal", "tool": ["type": "tool_reference", "name": .string(name)]])
        }
    }

    /// The tools the runner runs, by name: the thread's runnable tools with the overrides applied.
    func runnableTools() -> OrderedDict<any BetaRunnableTool> {
        var tools = thread.state.runnableTools
        for (name, o) in toolOverrides.items {
            switch o {
            case .removed: tools[name] = nil
            case .tool(let t): tools[name] = t
            }
        }
        return tools
    }

    /// The names of the tools in the `tools` param, and the families of its toolsets.
    private func declaredTools() -> Set<String> {
        Set((paramsSnapshot()["tools"]?.arrayValue ?? []).map { $0["name"]?.stringValue ?? toolFamily($0) })
    }

    private func sendPendingToolChanges(hold: Bool) {
        // A turn that stopped on `pause_turn` is sent back to be continued, so it has to stay last.
        if hold || pendingToolChanges.isEmpty { return }
        thread.state.append([.param(["role": "system", "content": .array(pendingToolChanges)])])
        pendingToolChanges = []
    }

    /// The tool names currently available, after applying mid-conversation `tool_removal` / `tool_addition` blocks.
    private func availableNames() -> Set<String> {
        let pendingMessage: JSONValue = ["role": "system", "content": .array(pendingToolChanges)]
        return availableToolNames((messages ?? thread.messages) + [pendingMessage], runnableTools().keys)
    }

    /// The runnable toolsets among the thread's tools, and the ones the runner was given apart from them.
    func toolsetsByFamily() -> OrderedDict<BetaRunnableToolset> {
        var out = OrderedDict<BetaRunnableToolset>()
        for tool in thread.state.tools ?? [] {
            if let toolset = tool as? BetaRunnableToolset { out[toolset.toolsetName] = toolset }
        }
        for (family, toolset) in toolsets.items { out[family] = toolset }
        return out
    }

    private func toolsetFor(_ toolUse: BetaToolUseBlock) -> BetaRunnableToolset? {
        let families = toolsetsByFamily()
        guard let toolset = families[toolUse.toolsetName ?? ""] else {
            ToolDiagnostics.warn(
                "Toolset '\(quotedName(toolUse.toolsetName))' (member '\(quotedName(toolUse.name))') not found in tool runner. "
                    + "Registered toolsets: \(pythonList(families.keys)). "
                    + "If using a raw toolset definition, handle the tool call manually and use `append_messages()` to add the result. "
                    + "Otherwise, pass a `BetaRunnableToolset` / `BetaRunnableToolset` instance.")
            return nil
        }
        return toolset
    }


    // MARK: - Tool calls

    /// Runs the tool calls of the last message and returns their results as a user message, or `nil` if the
    /// message made no tool call (`generate_tool_call_response`). The response is cached: calling it again returns
    /// the same response. With `runToolsEagerly`, it reuses the results of the reply's calls that have run and runs
    /// the rest, including the ones `deferToolCall()` is holding, so that no call runs twice. A streamed reply is
    /// read to its end first.
    public func generateToolCallResponse() async throws -> BetaMessageParam? {
        try await generateToolCallResponseJSON()?.decode()
    }

    func generateToolCallResponseJSON() async throws -> JSONValue? {
        if let cachedToolCallResponse {
            runnerLog.debug("Returning cached tool call response.")
            return cachedToolCallResponse
        }
        let response = try await makeToolCallResponse()
        cachedToolCallResponse = response
        return response
    }

    private func makeToolCallResponse() async throws -> JSONValue? {
        guard let lastTurn else { return nil }
        let last = try await lastTurn.finalMessage().message
        guard last.role == "assistant", !last.content.isEmpty else { return nil }
        let toolUses: [BetaToolUseBlock] = last.content.compactMap { if case .toolUse(let t) = $0 { return t } else { return nil } }
        if toolUses.isEmpty { return nil }

        var results: [JSONValue] = []
        let toolsByName = runnableTools()
        let available = availableNames()
        var failedToolsets = Set<String>()
        let eagerCalls = eagerToolCalls

        for toolUse in toolUses {
            if let family = toolUse.toolsetName {
                if failedToolsets.contains(family) {
                    results.append(notExecutedResult(toolUse))
                    continue
                }
                // The result of a member that ran while the reply streamed is kept, so that it doesn't run twice.
                var memberResult: JSONValue
                if let ran = eagerCalls?.results[toolUse.id] {
                    memberResult = ran
                } else {
                    memberResult = try await runToolsetMember(toolUse)
                    eagerCalls?.record(toolUse, memberResult)
                }
                if memberResult["is_error"] == true && toolsetsByFamily().contains(family) { failedToolsets.insert(family) }
                results.append(memberResult)
                continue
            }
            if let ran = eagerCalls?.results[toolUse.id] {
                results.append(ran)
                continue
            }
            let tool = available.contains(toolUse.name) ? toolsByName[toolUse.name] : nil
            if tool == nil && toolsetsByFamily().contains(toolUse.name) {
                failedToolsets.insert(toolUse.name)
                results.append(malformedToolsetCallResult(toolUse))
                continue
            }
            let result: JSONValue
            if let tool {
                result = try await runTool(tool, toolUse)
            } else {
                ToolDiagnostics.warn(
                    "Tool '\(toolUse.name)' not found in tool runner. "
                        + "Available tools: \(pythonList(toolsByName.keys)). "
                        + "If using a raw tool definition, handle the tool call manually and use `append_messages()` to add the result. "
                        + "Otherwise, pass the tool using `beta_async_tool(func)` or a `@beta_async_tool` decorated function.")
                result = [
                    "type": "tool_result", "tool_use_id": .string(toolUse.id),
                    "content": .string("Error: Tool '\(toolUse.name)' not found"), "is_error": true,
                ]
            }
            eagerCalls?.record(toolUse, result)
            results.append(result)
        }
        return ["role": "user", "content": .array(results)]
    }

    func runTool(_ tool: any BetaRunnableTool, _ toolUse: BetaToolUseBlock) async throws -> JSONValue {
        do {
            let content = try await tool.call(.object(toolUse.input))
            return ["type": "tool_result", "tool_use_id": .string(toolUse.id), "content": toolResultContent(content)]
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as ToolError {
            return ["type": "tool_result", "tool_use_id": .string(toolUse.id), "content": toolErrorContent(error), "is_error": true]
        } catch {
            runnerLog.exception("Error occurred while calling tool: \(tool.name)", error)
            return ["type": "tool_result", "tool_use_id": .string(toolUse.id), "content": toolErrorContent(error), "is_error": true]
        }
    }

    func runToolsetMember(_ toolUse: BetaToolUseBlock) async throws -> JSONValue {
        guard let toolset = toolsetFor(toolUse) else {
            return toolsetResultBlock(
                toolUse,
                .string("Error: Toolset '\(quotedName(toolUse.toolsetName))' member '\(quotedName(toolUse.name))' not found"),
                isError: true)
        }
        return try await toolset.toolResultJSON(toolUse)
    }

    /// Called with each event of a streamed reply as the reader asks for it (`_run_tools_while_streaming`): runs the
    /// call the previous event showed the model has moved on from, then follows `event`. Asking for the next event is
    /// how the reader says it is done with the one it holds, and the next event is read first, so that no call runs
    /// once reading the reply has failed.
    func runToolsWhileStreaming(_ event: ParsedBetaMessageStreamEvent, _ calls: EagerToolCalls) async throws {
        if let movedOnFrom = calls.movedOnFrom {
            calls.movedOnFrom = nil
            let name = movedOnFrom.name
            var family = movedOnFrom.toolsetName
            let tool = family == nil && availableNames().contains(name) ? runnableTools()[name] : nil
            if family == nil && tool == nil && toolsetsByFamily().contains(name) {
                // A call named like a toolset, with no `toolset_name`, is a malformed toolset call.
                family = name
                calls.waitingToolsets.insert(name)
            }
            if let family {
                // A toolset runs its calls in the model's order. So once one of its calls waits for the tool
                // response, or fails, its later calls wait for the tool response too.
                if calls.isHeld(movedOnFrom) { calls.waitingToolsets.insert(family) }
                if !calls.waitingToolsets.contains(family) {
                    runningEagerTool = true
                    defer { runningEagerTool = false }
                    let memberResult = try await runToolsetMember(movedOnFrom)
                    calls.record(movedOnFrom, memberResult)
                    if memberResult["is_error"] == true { calls.waitingToolsets.insert(family) }
                }
            } else if let tool, !calls.isHeld(movedOnFrom) {
                // A call to a tool the runner doesn't have gets its error result with the tool response.
                runningEagerTool = true
                defer { runningEagerTool = false }
                calls.record(movedOnFrom, try await runTool(tool, movedOnFrom))
            }
        }
        calls.movedOnFrom = calls.track(event)
    }

    /// Hold a tool call of the current reply until you are done with the reply (`defer_tool_call`).
    func holdToolCall(_ id: String) {
        eagerToolCalls?.hold(id)
    }

    /// The tool calls of the current reply that `deferToolCall()` is holding (`deferred_tool_calls`).
    func heldToolCalls() -> [BetaToolUseBlock] {
        eagerToolCalls?.held() ?? []
    }
}

/// A tool runner that yields each assistant message (`BetaAsyncToolRunner`).
public typealias BetaToolRunner = BaseBetaToolRunner<BetaMessage, Never>

/// A tool runner that yields each assistant message parsed into `Output` (`BetaAsyncToolRunner[ResponseFormatT]`).
public typealias BetaParsedToolRunner<Output: Sendable> = BaseBetaToolRunner<ParsedBetaMessage<Output>, Output>

/// A tool runner that yields the stream of each assistant message (`BetaAsyncStreamingToolRunner`), parsed into
/// `Output` when the runner has an output format (`Never` when it has none).
public typealias BetaStreamingToolRunner<Output: Sendable> = BaseBetaToolRunner<BetaMessageStream<Output>, Output>

extension BaseBetaToolRunner where Item == BetaMessage, Output == Never {
    init(thread: MessageThread, options: ToolRunnerRequestOptions, tools: [any BetaToolLike] = [], maxIterations: Int?) throws {
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations,
                      kind: .message { $0.message }, parser: nil)
    }

    /// Runs the tool loop with the params of its requests, its tools and toolsets, and a client
    /// (`BetaAsyncToolRunner(params=..., tools=..., client=...)`).
    public init(params: BetaToolRunnerParams, tools: [any BetaToolLike], client: BaseClient,
                options: ToolRunnerRequestOptions = ToolRunnerRequestOptions(), maxIterations: Int? = nil) throws
    {
        let thread = try toolRunnerThread(params: params, client: client, outputFormat: nil)
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations)
    }

    /// Consumes the loop and returns the last message (`until_done()`).
    public func untilDone() async throws -> BetaMessage {
        try await untilDoneParsed().message
    }
}

extension BaseBetaToolRunner where Item == ParsedBetaMessage<Output> {
    init(thread: MessageThread, options: ToolRunnerRequestOptions, tools: [any BetaToolLike] = [], maxIterations: Int?,
         parser: @escaping OutputParser<Output>) throws
    {
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations, kind: .message { $0 },
                      parser: parser)
    }

    /// Consumes the loop and returns the last message (`until_done()`).
    public func untilDone() async throws -> ParsedBetaMessage<Output> {
        try await untilDoneParsed()
    }
}

extension BaseBetaToolRunner where Item == ParsedBetaMessage<Output>, Output: StructuredOutput {
    /// Runs the tool loop with the params of its requests, its tools and toolsets, and a client, parsing each reply
    /// into `outputFormat` (`BetaAsyncToolRunner(params={..., "output_format": ...}, tools=..., client=...)`).
    public init(params: BetaToolRunnerParams, outputFormat: Output.Type, tools: [any BetaToolLike], client: BaseClient,
                options: ToolRunnerRequestOptions = ToolRunnerRequestOptions(), maxIterations: Int? = nil) throws
    {
        let thread = try toolRunnerThread(params: params, client: client, outputFormat: try toolRunnerOutputFormat(Output.self))
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations,
                      parser: structuredOutputParser(Output.self))
    }
}

extension BaseBetaToolRunner where Item == BetaMessageStream<Output> {
    init(thread: MessageThread, options: ToolRunnerRequestOptions, tools: [any BetaToolLike] = [], maxIterations: Int?,
         runToolsEagerly: Bool, parser: OutputParser<Output>?) throws
    {
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations,
                      kind: .stream({ $0 }, runToolsEagerly: runToolsEagerly), parser: parser)
    }

    /// Runs the tool loop with the params of its requests, its tools and toolsets, and a client, streaming each reply
    /// (`BetaAsyncStreamingToolRunner(params=..., tools=..., client=...)`).
    ///
    /// - Parameter runToolsEagerly: Run each tool as soon as its call is complete, before the reply finishes. See
    ///   `client.beta.messages.streamingToolRunner(...)`.
    public init(params: BetaToolRunnerParams, tools: [any BetaToolLike], client: BaseClient,
                options: ToolRunnerRequestOptions = ToolRunnerRequestOptions(), maxIterations: Int? = nil,
                runToolsEagerly: Bool = false) throws where Output == Never
    {
        let thread = try toolRunnerThread(params: params, client: client, outputFormat: nil)
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations,
                      runToolsEagerly: runToolsEagerly, parser: nil)
    }

    /// Like `init(params:tools:client:options:maxIterations:runToolsEagerly:)`, parsing each reply into
    /// `outputFormat`.
    public init(params: BetaToolRunnerParams, outputFormat: Output.Type, tools: [any BetaToolLike], client: BaseClient,
                options: ToolRunnerRequestOptions = ToolRunnerRequestOptions(), maxIterations: Int? = nil,
                runToolsEagerly: Bool = false) throws where Output: StructuredOutput
    {
        let thread = try toolRunnerThread(params: params, client: client, outputFormat: try toolRunnerOutputFormat(Output.self))
        try self.init(thread: thread, options: options, tools: tools, maxIterations: maxIterations,
                      runToolsEagerly: runToolsEagerly, parser: structuredOutputParser(Output.self))
    }

    /// Consumes the loop and returns the last message (`until_done()`).
    public func untilDone() async throws -> ParsedBetaMessage<Output> {
        try await untilDoneParsed()
    }

    /// Hold a tool call of the current reply until you are done with the reply, which is when it runs without
    /// `runToolsEagerly`: at the end of the loop body, or when you call `generateToolCallResponse()`
    /// (`defer_tool_call`).
    ///
    /// With `runToolsEagerly` the runner otherwise runs each call while the reply streams, once the model has moved
    /// on from it: when the next block starts, or the reply stops with `tool_use`. The call runs when you ask for the
    /// event after that one, so you can hold it while you handle any event up to and including that one. The other
    /// calls of the reply still run early, except the later calls of the same toolset, which a toolset runs in
    /// order. It does nothing for a call that has run, outside the loop body, and without `runToolsEagerly`.
    ///
    /// ```swift
    /// for try await stream in runner {
    ///     for try await event in stream {
    ///         if case .contentBlockStart(let start) = event, case .toolUse(let call) = start.contentBlock, call.name == "delete_file" {
    ///             await runner.deferToolCall(call)
    ///         }
    ///     }
    ///     // No `delete_file` call has run yet.
    /// }
    /// ```
    public func deferToolCall(_ toolUse: BetaToolUseBlock) {
        holdToolCall(toolUse.id)
    }

    /// `deferToolCall(_:)` by the id of the call's `tool_use` block.
    public func deferToolCall(id: String) {
        holdToolCall(id)
    }

    /// The tool calls of the current reply that `deferToolCall()` is holding, in the model's order, as their
    /// `tool_use` blocks (`deferred_tool_calls`).
    ///
    /// A call is in the list once its block has finished streaming, so read the list when you are done with the
    /// stream. A call that has run is not in it. It is empty without `runToolsEagerly`. Held calls are listed
    /// whatever the reply's `stop_reason`, because `generateToolCallResponse()` runs them whatever it is.
    public var deferredToolCalls: [BetaToolUseBlock] {
        heldToolCalls()
    }
}

/// The thread of a runner made from the params of its requests (`_for_tool_runner`).
func toolRunnerThread(params: BetaToolRunnerParams, client: BaseClient, outputFormat: [String: JSONValue]?) throws -> MessageThread {
    try rejectThreadParam(params["thread"])
    if outputFormat != nil, let format = params["output_config"]?["format"], !format.isNull {
        throw outputFormatConflictError()
    }
    var fields = params
    let messages = fields.removeValue(forKey: "messages")?.arrayValue ?? []
    let definitions = fields.removeValue(forKey: "tools")?.arrayValue ?? []
    let threading = fields.removeValue(forKey: "thread") != .bool(false)
    return try MessageThread.forToolRunner(client: client, fields: fields, messages: messages, tools: definitions,
                                           threading: threading, outputFormat: outputFormat)
}

/// The `output_config.format` a runner with the output format `Output` sends (`JSONOutputFormat.format_param`).
func toolRunnerOutputFormat<Output: StructuredOutput>(_ type: Output.Type) throws -> [String: JSONValue] {
    ["type": "json_schema", "schema": .object(try jsonOutputFormat(Output.self))]
}

func outputFormatConflictError() -> AnthropicError {
    AnthropicError(
        "Both output_format and output_config.format were provided. Please use only output_config.format (output_format is deprecated).")
}

/// The tool calls of one streamed reply, for a tool runner with `runToolsEagerly` (`EagerToolCalls`). Only used from
/// the runner's actor.
final class EagerToolCalls: @unchecked Sendable {
    /// The result of each call that has run, by `tool_use` id.
    var results: [String: JSONValue] = [:]
    /// The `tool_use` blocks that have finished streaming, in the model's order.
    private var finished: [BetaToolUseBlock] = []
    /// The ids of the calls that `deferToolCall()` is holding.
    private var heldIDs = Set<String>()
    /// The toolsets that have a call waiting for the tool response. Their later calls wait for it too.
    var waitingToolsets = Set<String>()
    /// The last `tool_use` block to close, until the model moves on from it.
    private var closed: BetaToolUseBlock?
    /// Whether a refusal has handed the reply to a fallback model.
    private var fallback = false
    /// The call the last event showed the model has moved on from; it runs when the reader asks for the next event.
    var movedOnFrom: BetaToolUseBlock?

    func hold(_ id: String) {
        if results[id] == nil { heldIDs.insert(id) }
    }

    func isHeld(_ toolUse: BetaToolUseBlock) -> Bool { heldIDs.contains(toolUse.id) }

    func held() -> [BetaToolUseBlock] { finished.filter { heldIDs.contains($0.id) } }

    func record(_ toolUse: BetaToolUseBlock, _ result: JSONValue) {
        heldIDs.remove(toolUse.id)
        results[toolUse.id] = result
    }

    /// Follows the reply, and returns the call that `event` shows the model has moved on from, if any.
    ///
    /// A call's own `content_block_stop` isn't enough, because a reply that is cut off closes its last call too.
    /// After a `fallback` block no call is returned, so the rest wait for the reply to end.
    func track(_ event: ParsedBetaMessageStreamEvent) -> BetaToolUseBlock? {
        switch event {
        case .contentBlockStop(let stop):
            if case .toolUse(let toolUse) = stop.contentBlock {
                finished.append(toolUse)
                closed = fallback ? nil : toolUse
            }
            return nil
        case .contentBlockStart(let start):
            if case .fallback = start.contentBlock {
                // The refusal that led to the fallback may have cut off the call before it.
                fallback = true
                closed = nil
                return nil
            }
        case .messageDelta(let delta) where delta.delta.stopReason == .toolUse:
            break
        default:
            return nil
        }
        let movedOnFrom = closed
        closed = nil
        return movedOnFrom
    }
}

/// Python's `str(list_of_strings)`.
func pythonList(_ items: [String]) -> String {
    "[" + items.map(pythonStringRepr).joined(separator: ", ") + "]"
}

let MAX_NAMED_ACTIONS = 10

/// The error result for a call that is named after a toolset in the run but has no `toolset_name`.
func malformedToolsetCallResult(_ toolUse: BetaToolUseBlock) -> JSONValue {
    let detail = malformedCallDetail(toolUse.input)
    return [
        "type": "tool_result", "tool_use_id": .string(toolUse.id),
        "content": .string(
            "Error: the '\(quotedName(toolUse.name))' toolset could not run this call\(detail); nothing in the batch was executed"),
        "is_error": true,
    ]
}

func malformedCallDetail(_ input: BetaToolInput) -> String {
    guard let actions = input["actions"] else {
        if let action = input["action"]?.stringValue {
            return ": the call has no 'actions' list (action: '\(quotedName(action))')"
        }
        return ": the call has no 'actions' list"
    }
    if case .string = actions { return ": 'actions' is text, not a list of actions" }
    guard case .array(let list) = actions else { return ": 'actions' is not a list of actions" }
    if list.isEmpty { return ": the 'actions' list is empty" }
    var names: [String] = []
    for (i, entry) in list.enumerated() {
        guard let name = entry["action"]?.stringValue else {
            return ": action \(i) must be an object with a string 'action' field"
        }
        names.append("'\(quotedName(name))'")
    }
    let more = names.count - MAX_NAMED_ACTIONS
    let shown = names.prefix(MAX_NAMED_ACTIONS).joined(separator: ", ") + (more > 0 ? ", and \(more) more" : "")
    return ": its actions could not be run as sent (actions: \(shown))"
}
