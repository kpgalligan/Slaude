import Foundation

// Messages streams read with their JSON kept, for a consumer that keeps a conversation's history as the JSON it
// received and sends it back unchanged on every request: the typed models drop fields this SDK version does not know
// and `JSONValue` loses key order, either of which changes the bytes of an earlier turn.

extension BetaMessagesResource {
    /// Creates a Message, streamed, from a request body given as JSON, and reads its events with their JSON kept,
    /// building the Message as JSON as they arrive (`JSONMessageStream`): the JSON counterpart of `stream(...)`.
    ///
    /// The body is sent as it is: its keys in their order, every field (including ones this SDK does not model),
    /// explicit `null`s and numbers as written; `stream` is set to `true`. Build it from the history you received
    /// (`JSONMessageStream.messageParam`) and typed values where you have them (`RawJSON(encoding:)`, which sorts
    /// their keys, so they too are the same bytes on every request). The other arguments are `createStreaming`'s.
    public func stream(body: RawJSON, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil,
                       workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                       extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> JSONMessageStream<BetaRawMessageStreamEvent>
    {
        JSONMessageStream(events: try await createStreaming(body: body, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID,
                                                            extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody,
                                                            timeout: timeout))
    }

    /// Like `stream(body:)`, without the accumulation: the events, each with its JSON and its typed event, as
    /// `createStreaming(...)` gives the typed events alone.
    public func createStreaming(body: RawJSON, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil,
                                workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                                extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Stream<JSONStreamEvent<BetaRawMessageStreamEvent>>
    {
        let headers = mergeHeaders(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")),
                                                  ("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]),
                                   extraHeaders)
        let options = try jsonStreamingOptions(client, body, headers: headers, extraQuery: extraQuery, extraBody: extraBody,
                                                  timeout: timeout, qualifiers: ["beta": "true"])
        return try await client.requestJSONStreamResponse(BetaRawMessageStreamEvent.self, options).parse()
    }
}

extension MessagesResource {
    /// Creates a Message, streamed, from a request body given as JSON, and reads its events with their JSON kept
    /// (`JSONMessageStream`). See `beta.messages.stream(body:)`.
    public func stream(body: RawJSON, userProfileID: String? = nil, workspaceID: String? = nil,
                       extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                       timeout: Timeout? = nil) async throws -> JSONMessageStream<RawMessageStreamEvent>
    {
        JSONMessageStream(events: try await createStreaming(body: body, userProfileID: userProfileID, workspaceID: workspaceID,
                                                            extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody,
                                                            timeout: timeout))
    }

    /// Like `stream(body:)`, without the accumulation. See `beta.messages.createStreaming(body:)`.
    public func createStreaming(body: RawJSON, userProfileID: String? = nil, workspaceID: String? = nil,
                                extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                                timeout: Timeout? = nil) async throws -> Stream<JSONStreamEvent<RawMessageStreamEvent>>
    {
        let headers = mergeHeaderLayers(stripNotGiven([("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]),
                                        extraHeaders)
        let options = try jsonStreamingOptions(client, body, headers: headers, extraQuery: extraQuery, extraBody: extraBody,
                                                  timeout: timeout, qualifiers: nil)
        return try await client.requestJSONStreamResponse(RawMessageStreamEvent.self, options).parse()
    }
}

/// The options of a streamed Messages create whose body is `body` with `stream: true`.
func jsonStreamingOptions(_ client: BaseClient, _ body: RawJSON, headers: Headers?, extraQuery: Query?, extraBody: Body?,
                             timeout: Timeout?, qualifiers: [String: String]?) throws -> FinalRequestOptions
{
    guard case .object = body else { throw ArgumentTypeError("Expected the request body to be a JSON object") }
    var body = body
    body["stream"] = true
    if let model = body["model"]?.stringValue {
        warnIfDeprecatedModel(model)
        warnIfThinkingEnabledDeprecated(model, thinking: body["thinking"]?.jsonValue)
    }
    var options = try client.makeRequestOptions(method: "post", url: "/v1/messages", headers: headers, extraQuery: extraQuery,
                                                extraBody: extraBody, timeout: timeout, mode: .parsed, spanName: "anthropic.messages.create",
                                                spanRoute: "/v1/messages", spanBodyAttributes: messagesCreateRequestAttributes,
                                                qualifiers: qualifiers)
    options.setRawJSONBody(body)
    return options
}

/// A Messages stream read with every event's JSON kept, which builds the Message as JSON as it goes
/// (`messages.stream(body:)`, `beta.messages.stream(body:)`).
///
/// Its names follow `MessageStream`'s: `currentMessageSnapshot`, `messageComplete`, `getFinalMessage()`.
///
/// Iterating it gives each event with its JSON and its typed event (`JSONStreamEvent`). Reading is lenient: an
/// event, block or delta type this SDK version does not know, or an event whose fields drifted from the schema, is
/// handed out with its JSON (the typed event is then the `unknown` case) and the stream goes on. The accumulated
/// Message (`currentMessageSnapshot`) is built from the JSON alone (`JSONMessageAccumulator`), so it keeps every field.
///
/// An `error` event ends the stream with the typed error for its `error.type` (an `OverloadedError` for
/// `overloaded_error`). A stream never ends normally before `message_stop`: reading one that is cancelled (its task,
/// or `close()`) throws `CancellationError`, and one whose body ended or whose connection broke first throws
/// `StreamEndedEarlyError`. Every later read throws the same error, and `getFinalMessage()` throws it rather than
/// return the partial Message. `currentMessageSnapshot` stays readable as accumulated so far, with `messageComplete`
/// false.
///
/// Like `Stream`, it has a single position; don't iterate it from several tasks at once.
public final class JSONMessageStream<Event: LenientStreamEvent>: AsyncSequence, @unchecked Sendable {
    public typealias Element = JSONStreamEvent<Event>

    /// The events as read, before they are accumulated.
    public let events: Stream<JSONStreamEvent<Event>>
    /// The Message built so far.
    public private(set) var accumulator: JSONMessageAccumulator
    private var iterator: Stream<JSONStreamEvent<Event>>.AsyncIterator?
    private var done = false
    private let tracedMessage: StreamedMessage?

    public init(events: Stream<JSONStreamEvent<Event>>) {
        self.events = events
        // As the typed streams do: with fine-grained tool streaming, a string the input stops in is kept.
        let beta = events.response.request.headers["anthropic-beta"] ?? ""
        self.accumulator = JSONMessageAccumulator(toolInputMode: beta.contains("fine-grained-tool-streaming-2025-05-14") ? .trailingStrings : .on)
        // The span of the call takes its output content from the Message accumulated here.
        self.tracedMessage = shareMessageSnapshot(events)
    }

    public var response: HTTPResponse { events.response }
    public var requestID: String? { response.headers["request-id"] }
    public var workspaceID: String? { response.headers["anthropic-workspace-id"] }

    /// The Message built so far, as JSON: `message_start`'s `message` with the blocks and deltas applied; `nil` before
    /// `message_start`. It is partial until `messageComplete`.
    public var currentMessageSnapshot: RawJSON? { accumulator.message }
    /// The Message as a turn of a later request's `messages`: `{"role": "assistant", "content": [...]}`.
    public var messageParam: RawJSON? { accumulator.messageParam }
    /// Whether `message_stop` was received, so that `currentMessageSnapshot` is the whole Message.
    public var messageComplete: Bool { accumulator.messageComplete }

    /// Closes the response, which cancels the request. The Message stays as accumulated so far; before
    /// `message_stop`, a read after this throws `CancellationError`.
    public func close() { events.close() }

    /// Reads the remaining events.
    public func untilDone() async throws {
        while try await nextEvent() != nil {}
    }

    /// Reads the remaining events and returns the whole Message. It never returns a partial one: a stream that was
    /// cancelled throws `CancellationError`, and one that ended before `message_stop` throws `StreamEndedEarlyError`.
    public func getFinalMessage() async throws -> RawJSON {
        try await untilDone()
        guard let message = accumulator.message else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
        guard messageComplete else { throw StreamEndedEarlyError(response: response) }
        return message
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let stream: JSONMessageStream<Event>
        public mutating func next() async throws -> JSONStreamEvent<Event>? { try await stream.nextEvent() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(stream: self) }

    func nextEvent() async throws -> JSONStreamEvent<Event>? {
        if done { return nil }
        if iterator == nil { iterator = events.makeAsyncIterator() }
        guard let event = try await iterator?.next() else {
            done = true
            return nil
        }
        do {
            try accumulator.apply(event.json)
        } catch {
            withholdMessageSnapshot(events)
            // The Message cannot be built past this event, so the stream ends here and every later read throws this.
            events.fail(error)
            throw error
        }
        if tracedMessage != nil, ["content_block_stop", "message_delta", "message_stop"].contains(event.type ?? "") {
            tracedMessage?.updateSnapshot(accumulator.message.map(TracedMessageJSON.init))
        }
        return event
    }
}

/// The Message a call's span takes its output content from, converted only when the span reads it.
private struct TracedMessageJSON: Encodable, Sendable {
    let message: RawJSON
    func encode(to encoder: any Encoder) throws { try message.jsonValue.encode(to: encoder) }
}

/// Builds a streamed Message as JSON from its events' JSON, keeping every field as received
/// (`lib/streaming/_beta_messages.accumulate_event`, over JSON rather than models).
///
/// * The Message is `message_start`'s `message` object, and each `content_block_start` appends its `content_block`
///   object; both as received.
/// * `text_delta` appends to a `text` block's `text`; `thinking_delta` to a `thinking` block's `thinking`;
///   `signature_delta` sets a `thinking` block's `signature`; `citations_delta` appends its `citation` to a `text`
///   block's `citations`; `compaction_delta` sets a `compaction` block's fields.
/// * A block's `input_json_delta` strings are concatenated and parsed at its `content_block_stop` into its `input`,
///   in the model's key order. `message` parses a block whose input is still arriving as far as it goes.
/// * `message_delta` sets `stop_reason`, `stop_sequence` and `stop_details`, and the delta's other fields, its
///   `context_management` and `input_transformations` when they are not `null`; its `usage` counts are totals and
///   replace the Message's (`output_tokens` always, the others when not `null`).
/// * A fallback block names the model that served the response, which becomes the Message's `model`.
/// * An event before `message_start`, and an event, block or delta type this does not know, leave the Message as it is.
public struct JSONMessageAccumulator: Sendable {
    private var head: RawJSONObject?
    private var blocks: [RawJSON] = []
    /// The text each delta appended to a block's string field, kept apart from the block so that it grows in place.
    private var appended: [Int: [String: String]] = [:]
    /// The `input_json_delta` text of each block whose `content_block_stop` has not arrived.
    private var inputJSON: [Int: String] = [:]
    private let toolInputMode: PartialJSONMode
    /// Whether `message_stop` was received.
    public private(set) var messageComplete = false

    /// `toolInputMode` is how a tool input is parsed: `.on` drops a string it stops in, `.trailingStrings` keeps it
    /// (with the `fine-grained-tool-streaming-2025-05-14` beta, an input may stop anywhere).
    public init(toolInputMode: PartialJSONMode = .on) {
        self.toolInputMode = toolInputMode
    }

    /// The Message built so far.
    public var message: RawJSON? {
        guard var m = head else { return nil }
        var content: [RawJSON] = []
        content.reserveCapacity(blocks.count)
        for (i, block) in blocks.enumerated() {
            guard appended[i] != nil || inputJSON[i] != nil, case .object(var b) = block else {
                content.append(block)
                continue
            }
            Self.fold(appended[i], into: &b)
            if let buf = inputJSON[i], !buf.isEmpty, let input = try? Self.parseInput(buf, mode: toolInputMode) { b["input"] = input }
            content.append(.object(b))
        }
        m["content"] = .array(content)
        return .object(m)
    }

    /// The Message as a turn of a later request's `messages`: `{"role": "assistant", "content": [...]}`.
    public var messageParam: RawJSON? {
        guard let message else { return nil }
        return ["role": message["role"] ?? "assistant", "content": message["content"] ?? []]
    }

    /// The `input_json_delta` text received so far for the block at `index`, until its `content_block_stop`.
    public func partialInputJSON(at index: Int) -> String? { inputJSON[index] }

    /// Applies one event (its `data` JSON). Throws only when a tool input that is complete cannot be parsed.
    public mutating func apply(_ event: RawJSON) throws {
        let type = event["type"]?.stringValue
        if head == nil {
            guard type == "message_start", case .object(let m)? = event["message"] else { return }
            head = m
            blocks = m["content"]?.arrayValue ?? []
            return
        }
        switch type {
        case "content_block_start":
            guard let block = event["content_block"] else { return }
            blocks.append(block)
            if block["type"]?.stringValue == "fallback", let model = block["to"]?["model"] {
                // the final hop's fallback block names the model that served the response
                head?["model"] = model
            }
        case "content_block_delta":
            guard let index = event["index"]?.intValue, blocks.indices.contains(index), let delta = event["delta"] else { return }
            applyDelta(delta, to: index)
        case "content_block_stop":
            guard let index = event["index"]?.intValue, blocks.indices.contains(index) else { return }
            try finishBlock(index)
        case "message_delta":
            applyMessageDelta(event)
        case "message_stop":
            messageComplete = true
        default:
            break
        }
    }

    private mutating func applyDelta(_ delta: RawJSON, to index: Int) {
        let blockType = blocks[index]["type"]?.stringValue
        switch delta["type"]?.stringValue {
        case "text_delta":
            if blockType == "text", let text = delta["text"]?.stringValue { appended[index, default: [:]]["text", default: ""] += text }
        case "thinking_delta":
            if blockType == "thinking", let text = delta["thinking"]?.stringValue {
                appended[index, default: [:]]["thinking", default: ""] += text
            }
        case "signature_delta":
            if blockType == "thinking", let signature = delta["signature"] { withBlock(index) { $0["signature"] = signature } }
        case "citations_delta":
            if blockType == "text", let citation = delta["citation"] {
                withBlock(index) { block in
                    block.modifyValue(forKey: "citations") { citations in
                        guard case .array(var list) = citations else {
                            citations = [citation]
                            return
                        }
                        citations = .null
                        list.append(citation)
                        citations = .array(list)
                    }
                }
            }
        case "compaction_delta":
            if blockType == "compaction", case .object(let fields) = delta {
                withBlock(index) { block in
                    for (k, v) in fields where k != "type" { block[k] = v }
                }
            }
        case "input_json_delta":
            if let partial = delta["partial_json"]?.stringValue { inputJSON[index, default: ""] += partial }
        default:
            break
        }
    }

    private mutating func finishBlock(_ index: Int) throws {
        if let extra = appended.removeValue(forKey: index) { withBlock(index) { Self.fold(extra, into: &$0) } }
        if let buf = inputJSON[index], !buf.isEmpty {
            let input = try Self.parseInput(buf, mode: toolInputMode)
            withBlock(index) { $0["input"] = input }
        }
        inputJSON[index] = nil
    }

    private mutating func applyMessageDelta(_ event: RawJSON) {
        guard var m = head else { return }
        head = nil
        if case .object(let delta)? = event["delta"] {
            for (k, v) in delta where k == "stop_reason" || k == "stop_sequence" || k == "stop_details" || !v.isNull { m[k] = v }
        }
        for key in ["context_management", "input_transformations"] {
            if let v = event[key], !v.isNull { m[key] = v }
        }
        if case .object(let usage)? = event["usage"] {
            // the counts are cumulative totals, and the ones left out (or `null`) keep their value
            m.modifyValue(forKey: "usage") { current in
                var totals = current.objectValue ?? [:]
                current = .null
                for (k, v) in usage where k == "output_tokens" || !v.isNull { totals[k] = v }
                current = .object(totals)
            }
        }
        head = m
    }

    private mutating func withBlock(_ index: Int, _ body: (inout RawJSONObject) -> Void) {
        guard blocks.indices.contains(index), case .object(var block) = blocks[index] else { return }
        blocks[index] = .null
        body(&block)
        blocks[index] = .object(block)
    }

    private static func fold(_ extra: [String: String]?, into block: inout RawJSONObject) {
        guard let extra else { return }
        for field in extra.keys.sorted() {
            block.modifyValue(forKey: field) { value in value = .string((value.stringValue ?? "") + (extra[field] ?? "")) }
        }
    }

    private static func parseInput(_ buf: String, mode: PartialJSONMode) throws -> RawJSON {
        do {
            return try JSONTextParser.parse(Data(buf.utf8), mode: mode, maxDepth: JSONTextParser.toolInputMaxDepth)
        } catch {
            throw toolInputError(error, buf)
        }
    }
}
