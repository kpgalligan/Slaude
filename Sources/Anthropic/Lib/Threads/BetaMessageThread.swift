// Port of `anthropic/lib/threads/__init__.py`, `_beta_threads.py` (`BetaAsyncMessageThread`), the public half of
// `_params.py` (`ThreadParams`, `UnsupportedRequestBehavior`) and `_stream_managers.py`
// (`AsyncThreadMessageStreamManager`): `client.beta.messages.thread(...)` and the thread it returns.
//
// The thread's state (`_thread_state.py`) and the sending half the tool runners share live in
// `Lib/Tools/Threads/` (`ThreadState`, `MessageThread`); this file is the public API on top of them.

import Foundation

/// What a thread does with a request the server cannot thread (`UnsupportedRequestBehavior`): `.error`, the default,
/// raises the API's error, and `.continueUnthreaded` sends that turn and every later one with the full history and no
/// `thread`.
public enum UnsupportedRequestBehavior: String, Sendable, Hashable {
    case error
    case continueUnthreaded = "continue_unthreaded"
}

/// A message given to a thread (`BetaMessageParam | BetaMessage`): a request param, or a reply the thread received.
public struct BetaThreadMessage: Sendable {
    let value: ThreadMessage
}

/// A value a thread takes as a message: a `BetaMessageParam`, a message written as JSON, or a reply
/// (`BetaMessage` / `ParsedBetaMessage`), which the thread recognises as the one it recorded.
public protocol BetaThreadMessageLike: Sendable {
    func threadMessage() throws -> BetaThreadMessage
}

extension BetaMessageParam: BetaThreadMessageLike {
    public func threadMessage() throws -> BetaThreadMessage { BetaThreadMessage(value: .param(try JSONValue.from(self))) }
}

extension JSONValue: BetaThreadMessageLike {
    public func threadMessage() throws -> BetaThreadMessage { BetaThreadMessage(value: .param(self)) }
}

extension BetaMessage: BetaThreadMessageLike {
    public func threadMessage() throws -> BetaThreadMessage { BetaThreadMessage(value: .reply(self)) }
}

extension ParsedBetaMessage: BetaThreadMessageLike {
    public func threadMessage() throws -> BetaThreadMessage { BetaThreadMessage(value: .reply(message)) }
}

func threadMessages(_ messages: [any BetaThreadMessageLike]) throws -> [ThreadMessage] {
    try messages.map { try $0.threadMessage().value }
}

/// A thread as the arguments of one `thread(params:)` call for the whole conversation (`ThreadParams`): its request
/// fields, tools (function tools included), output format, full history and `unsupportedRequestBehavior`.
public struct ThreadParams<Output: Sendable>: Sendable {
    /// The request fields as the request body sends them (`max_tokens`, `model`, `system`, ...), without `messages`
    /// and `tools`.
    public var fields: [String: JSONValue]
    /// The full history, as the request body sends it.
    public var messages: [JSONValue]
    /// The tools as given, function tools included; `nil` when the thread has none.
    public var tools: [any BetaToolLike]?
    public var unsupportedRequestBehavior: UnsupportedRequestBehavior
    /// The `output_config.format` param of the output format (`output_format`), if the thread has one.
    let outputFormat: [String: JSONValue]?
    let parser: OutputParser<Output>?

    init(fields: [String: JSONValue], messages: [JSONValue], tools: [any BetaToolLike]?,
         unsupportedRequestBehavior: UnsupportedRequestBehavior, outputFormat: [String: JSONValue]?, parser: OutputParser<Output>?)
    {
        self.fields = fields
        self.messages = messages
        self.tools = tools
        self.unsupportedRequestBehavior = unsupportedRequestBehavior
        self.outputFormat = outputFormat
        self.parser = parser
    }

    /// One request field.
    public subscript(field: String) -> JSONValue? {
        get { fields[field] }
        set { fields[field] = newValue }
    }

    /// Whether the thread parses replies into an output format.
    public var hasOutputFormat: Bool { outputFormat != nil }
}

extension ThreadParams where Output == Never {
    /// Thread params without an output format.
    public init(fields: [String: JSONValue], messages: [JSONValue] = [], tools: [any BetaToolLike]? = nil,
                unsupportedRequestBehavior: UnsupportedRequestBehavior = .error)
    {
        self.init(fields: fields, messages: messages, tools: tools, unsupportedRequestBehavior: unsupportedRequestBehavior,
                  outputFormat: nil, parser: nil)
    }
}

/// The JSON object of an encodable params struct, without the fields left at their "not given" default.
private func jsonFields<T: Encodable>(_ params: T?) throws -> [String: JSONValue] {
    guard let params else { return [:] }
    return try JSONValue.from(params).objectValue ?? [:]
}

/// Per-turn overrides (`turn_overrides`) from the arguments of `send()` / `parse()` / `stream()` / `update()`.
func threadTurnOverrides(params: ThreadSendParams?, tools: [any BetaToolLike]?, extraHeaders: Headers?, extraQuery: Query?,
                         extraBody: Body?, timeout: Timeout?) throws -> TurnOverrides
{
    var fields = try jsonFields(params)
    if let tools { fields["tools"] = .array(try tools.map { try $0.toToolParam() }) }
    return TurnOverrides(
        fields: fields,
        options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout))
}

private let threadsUnavailableMessage =
    "Message threads are not available on this client; use `client.beta.messages.create()` with the full `messages` instead"

/// A conversation the server holds between turns, so each request sends only the new messages
/// (`BetaAsyncMessageThread`).
///
/// Create one with `client.beta.messages.thread(...)`. A thread runs one turn at a time: a `send()`, `parse()` or
/// `stream()` while another is in progress raises. Like upstream, a thread is not meant to be used from several tasks
/// at once beyond that check.
///
/// ```swift
/// let thread = try client.beta.messages.thread(maxTokens: 1024, model: "claude-sonnet-5")
/// let reply = try await thread.send(BetaMessageParam.user(.init(content: "Hello")))
/// let next = try await thread.send(BetaMessageParam.user(.init(content: "And then?")))  // sends only the new message
/// ```
public final class BetaMessageThread<Output: Sendable>: @unchecked Sendable {
    let inner: MessageThread
    let outputFormat: [String: JSONValue]?
    let parser: OutputParser<Output>?

    init(inner: MessageThread, outputFormat: [String: JSONValue]?, parser: OutputParser<Output>?) {
        self.inner = inner
        self.outputFormat = outputFormat
        self.parser = parser
        inner.state.outputFormat = outputFormat
    }

    /// Start a thread on `client` with the arguments of `client.beta.messages.thread(params:)`. Sends nothing.
    public convenience init(client: BaseClient, params: ThreadParams<Output>, extraHeaders: Headers? = nil,
                            extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) throws
    {
        if !supportsMessageThreads(client) { throw AnthropicError(threadsUnavailableMessage) }
        if params.outputFormat != nil, params.fields["output_config"]?["format"].map({ !$0.isNull }) == true {
            throw AnthropicError(
                "Both output_format and output_config.format were provided. Please use only output_config.format (output_format is deprecated).")
        }
        try rejectThreadParam(params.fields["thread"])
        var fields = params.fields
        fields.removeValue(forKey: "thread")
        let state = try ThreadState(
            fields: fields, messages: params.messages, tools: params.tools,
            options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            threading: true, unsupportedRequestBehavior: params.unsupportedRequestBehavior.rawValue)
        self.init(inner: MessageThread(client: client, state: state), outputFormat: params.outputFormat, parser: params.parser)
    }

    /// The full conversation: every message the server holds plus those staged for the next turn.
    public var messages: [BetaMessageParam] {
        inner.messages.map { (try? $0.decode(as: BetaMessageParam.self)) ?? .unknown($0) }
    }

    /// `messages` as the request body sends them.
    public var messagesJSON: [JSONValue] { inner.messages }

    /// The response `id` the next turn continues from, or `nil` when the next turn starts a new thread.
    public var previousMessageID: String? { inner.state.previousMessageID }

    /// The arguments of a `client.beta.messages.thread(params:)` call for the whole conversation.
    public var params: ThreadParams<Output> {
        let p = inner.state.params
        return ThreadParams(
            fields: p.fields, messages: p.messages, tools: p.tools,
            unsupportedRequestBehavior: UnsupportedRequestBehavior(rawValue: inner.state.unsupportedRequestBehavior) ?? .error,
            outputFormat: outputFormat, parser: parser)
    }

    /// Stage messages for the next turn without sending anything.
    public func append(_ messages: any BetaThreadMessageLike...) throws {
        inner.state.append(try threadMessages(messages))
    }

    /// Change the request fields and request options of all later turns without sending anything. `system` and
    /// `tools` cannot change once a turn has created the thread.
    public func update(tools: [any BetaToolLike]? = nil, params: ThreadSendParams? = nil, extraHeaders: Headers? = nil,
                       extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) throws
    {
        let overrides = try threadTurnOverrides(params: params, tools: nil, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                extraBody: extraBody, timeout: timeout)
        try inner.state.update(overrides, tools: tools)
    }

    /// A new, independent thread with a copy of this one's history, request fields, tools and request options, and
    /// no `previousMessageID`. Sends nothing.
    public func fork() -> BetaMessageThread<Output> {
        BetaMessageThread(inner: inner.fork(), outputFormat: outputFormat, parser: parser)
    }

    /// Send the staged messages and `messages` as one turn and return the reply. The other arguments apply to this
    /// turn only. Raises `AnthropicError` while another `send()` / `parse()` / `stream()` on this thread is in
    /// progress.
    @discardableResult
    public func send(_ messages: any BetaThreadMessageLike..., tools: [any BetaToolLike]? = nil, params: ThreadSendParams? = nil,
                     extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                     timeout: Timeout? = nil) async throws -> BetaMessage
    {
        let overrides = try threadTurnOverrides(params: params, tools: tools, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                extraBody: extraBody, timeout: timeout)
        return try await send(try threadMessages(messages), overrides: overrides)
    }

    func send(_ messages: [ThreadMessage], overrides: TurnOverrides) async throws -> BetaMessage {
        try await inner.send(messages, overrides: overrides)
    }

    /// Like `send()`, and parses the reply against the thread's output format into `parsedOutput`.
    @discardableResult
    public func parse(_ messages: any BetaThreadMessageLike..., tools: [any BetaToolLike]? = nil, params: ThreadSendParams? = nil,
                      extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                      timeout: Timeout? = nil) async throws -> ParsedBetaMessage<Output>
    {
        let overrides = try threadTurnOverrides(params: params, tools: tools, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                extraBody: extraBody, timeout: timeout)
        return try await parse(try threadMessages(messages), overrides: overrides)
    }

    func parse(_ messages: [ThreadMessage], overrides: TurnOverrides) async throws -> ParsedBetaMessage<Output> {
        try parseBetaResponse(try await send(messages, overrides: overrides), parser: parser)
    }

    /// Like `send()`, and returns the reply's stream. The turn is in progress until the stream's events run out or
    /// fail, or the stream is closed (or released).
    public func stream(_ messages: any BetaThreadMessageLike..., tools: [any BetaToolLike]? = nil, params: ThreadSendParams? = nil,
                       extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                       timeout: Timeout? = nil) async throws -> BetaThreadMessageStream<Output>
    {
        let overrides = try threadTurnOverrides(params: params, tools: tools, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                extraBody: extraBody, timeout: timeout)
        return try await stream(try threadMessages(messages), overrides: overrides)
    }

    func stream(_ messages: [ThreadMessage], overrides: TurnOverrides) async throws -> BetaThreadMessageStream<Output> {
        let raw = try await inner.openStream(messages, overrides: overrides)
        return BetaThreadMessageStream(stream: BetaMessageStream(rawStream: raw, parser: parser), state: inner.state)
    }

    /// Run the tool loop over this thread: call its function tools whenever the model asks for one, until a reply
    /// makes no tool call. The replies and tool results become part of the thread's history.
    public func toolRunner(maxIterations: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                           extraBody: Body? = nil, timeout: Timeout? = nil) throws -> BetaToolRunner
    {
        try BetaToolRunner(
            thread: inner,
            options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            maxIterations: maxIterations)
    }
}

/// A stream over one turn of a thread (`AsyncThreadMessageStreamManager`). The turn ends when the stream's events
/// run out or fail, when it is closed, and when it is released at the latest. The reply is recorded on the thread:
/// the whole reply if the stream reached `message_stop`, the partial reply (and a new thread for the next turn) if
/// it ended after `message_start`, and nothing if it ended before that.
public final class BetaThreadMessageStream<Output: Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = ParsedBetaMessageStreamEvent

    /// The underlying message stream.
    public let stream: BetaMessageStream<Output>
    private let state: ThreadState
    private let lock = NSLock()
    private var turnEnded = false

    init(stream: BetaMessageStream<Output>, state: ThreadState) {
        self.stream = stream
        self.state = state
    }

    deinit { endTurn() }

    public var response: HTTPResponse { stream.response }
    public var requestID: String? { stream.requestID }
    public var currentMessageSnapshot: ParsedBetaMessage<Output>? { stream.currentMessageSnapshot }

    /// Close the stream and end the turn.
    public func close() {
        stream.close()
        endTurn()
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let owner: BetaThreadMessageStream<Output>
        public mutating func next() async throws -> ParsedBetaMessageStreamEvent? { try await owner.nextEvent() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(owner: self) }

    func nextEvent() async throws -> ParsedBetaMessageStreamEvent? {
        do {
            guard let event = try await stream.nextEvent() else {
                endTurn()
                return nil
            }
            return event
        } catch {
            endTurn()
            throw error
        }
    }

    public func untilDone() async throws {
        while try await nextEvent() != nil {}
    }

    /// Waits until the stream has been read to completion and returns the reply. It never returns a partial reply:
    /// see `MessageStream.getFinalMessage()`.
    public func getFinalMessage() async throws -> ParsedBetaMessage<Output> {
        try await untilDone()
        guard let message = currentMessageSnapshot else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
        guard stream.messageComplete else { throw StreamEndedEarlyError(response: stream.response) }
        return message
    }

    public func getFinalText() async throws -> String {
        try await untilDone()
        return try await stream.getFinalText()
    }

    /// Just the text deltas of the reply. It ends, and throws, as the stream does.
    public var textStream: MessageTextStream {
        MessageTextStream { [self] in
            while let event = try await self.nextEvent() {
                if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta { return d.text }
            }
            return nil
        }
    }

    /// `_end_turn`: record the stream and free the thread, once.
    func endTurn() {
        let first = lock.withLock { () -> Bool in
            if turnEnded { return false }
            turnEnded = true
            return true
        }
        guard first else { return }
        defer { state.endTurn() }
        guard let snapshot = stream.currentMessageSnapshot?.message else { return }
        if stream.messageComplete {
            try? state.recordReply(snapshot)
        } else {
            try? state.recordPartialReply(snapshot, completedBlocks: stream.completedBlocks)
        }
    }
}

extension BetaMessagesResource {
    /// Start a message thread (`client.beta.messages.thread(...)`): a conversation the server holds between turns,
    /// so each request sends only the new messages. Sends nothing.
    ///
    /// - Parameters:
    ///   - messages: The history the first turn sends, ahead of what that turn is given.
    ///   - tools: Function tools and raw tool definitions; `thread.toolRunner()` runs the function tools.
    ///   - unsupportedRequestBehavior: What the thread does with a request the server cannot thread.
    ///   - params: The other `create()` fields the thread sends on each turn.
    public func thread(maxTokens: Int, model: ModelParam, messages: [any BetaThreadMessageLike] = [], tools: [any BetaToolLike]? = nil,
                       unsupportedRequestBehavior: UnsupportedRequestBehavior = .error, params: ThreadCreateParams? = nil,
                       extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                       timeout: Timeout? = nil) throws -> BetaMessageThread<Never>
    {
        try thread(params: try threadParams(maxTokens: maxTokens, model: model, messages: messages, tools: tools,
                                            unsupportedRequestBehavior: unsupportedRequestBehavior, params: params,
                                            outputFormat: nil, parser: nil as OutputParser<Never>?),
                   extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
    }

    /// Start a message thread whose replies `parse()` parses into `outputFormat`.
    public func thread<Output: StructuredOutput>(
        maxTokens: Int, model: ModelParam, messages: [any BetaThreadMessageLike] = [], tools: [any BetaToolLike]? = nil,
        outputFormat: Output.Type, unsupportedRequestBehavior: UnsupportedRequestBehavior = .error, params: ThreadCreateParams? = nil,
        extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) throws -> BetaMessageThread<Output> {
        try validateOutputConfigConflict(params?.outputConfig, hasOutputFormat: true)
        let format: [String: JSONValue] = ["type": "json_schema", "schema": .object(try jsonOutputFormat(Output.self))]
        return try thread(params: try threadParams(maxTokens: maxTokens, model: model, messages: messages, tools: tools,
                                                   unsupportedRequestBehavior: unsupportedRequestBehavior, params: params,
                                                   outputFormat: format, parser: structuredOutputParser(Output.self)),
                          extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
    }

    /// Start a thread from the params of another (`client.beta.messages.thread(**thread.params)`).
    public func thread<Output>(params: ThreadParams<Output>, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                               extraBody: Body? = nil, timeout: Timeout? = nil) throws -> BetaMessageThread<Output>
    {
        try BetaMessageThread(client: client, params: params, extraHeaders: extraHeaders, extraQuery: extraQuery,
                              extraBody: extraBody, timeout: timeout)
    }

    private func threadParams<Output>(
        maxTokens: Int, model: ModelParam, messages: [any BetaThreadMessageLike], tools: [any BetaToolLike]?,
        unsupportedRequestBehavior: UnsupportedRequestBehavior, params: ThreadCreateParams?, outputFormat: [String: JSONValue]?,
        parser: OutputParser<Output>?
    ) throws -> ThreadParams<Output> {
        var fields = try jsonFields(params)
        fields["max_tokens"] = .int(maxTokens)
        fields["model"] = .string(model.rawValue)
        return ThreadParams(fields: fields, messages: try threadMessages(messages).map(\.param), tools: tools,
                            unsupportedRequestBehavior: unsupportedRequestBehavior, outputFormat: outputFormat, parser: parser)
    }
}
