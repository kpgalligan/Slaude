import Foundation

/// A Messages stream that accumulates its events into the final message
/// (`lib/streaming/_messages.AsyncMessageStream`). Returned by `client.messages.stream(...)`.
///
/// Iterate it for the raw API events interleaved with helper events (`.text`, `.inputJson`, ...),
/// or use `textStream`, `untilDone()`, `getFinalMessage()` and `getFinalText()`. The stream is
/// a single sequence: every way of consuming it continues where the previous one stopped.
///
/// ```swift
/// let stream = try await client.messages.stream(maxTokens: 1024, messages: messages, model: "claude-opus-4-5")
/// for try await text in stream.textStream { print(text, terminator: "") }
/// let message = try await stream.getFinalMessage()
/// ```
///
/// `Output` is the structured output type when the stream was created with `outputFormat:`
/// (each text block is parsed into it when the block completes), and `Never` otherwise.
/// A stream must not be consumed from several tasks at once.
public final class MessageStream<Output: Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = ParsedMessageStreamEvent

    private let rawStream: Stream<RawMessageStreamEvent>
    private let parser: OutputParser<Output>?
    private var rawIterator: Stream<RawMessageStreamEvent>.AsyncIterator?
    private var pending: [ParsedMessageStreamEvent] = []
    private var snapshot: Message? {
        didSet { tracedMessage?.updateSnapshot(snapshot) }
    }
    private var tracedMessage: StreamedMessage?
    private var parsedOutputs: [Int: Output] = [:]
    private var jsonBufs: [Int: String] = [:]
    private var done = false

    public init(rawStream: Stream<RawMessageStreamEvent>, parser: OutputParser<Output>? = nil) {
        self.rawStream = rawStream
        self.parser = parser
        // The span of the call takes its output content from the Message accumulated here.
        self.tracedMessage = shareMessageSnapshot(rawStream)
    }

    /// The HTTP response the events are read from.
    public var response: HTTPResponse { rawStream.response }
    /// The `request-id` header of the response.
    public var requestID: String? { response.headers["request-id"] }
    /// The `anthropic-workspace-id` header of the response.
    public var workspaceID: String? { response.headers["anthropic-workspace-id"] }

    /// Closes the response and releases the connection. Called automatically once the stream has
    /// been read to completion.
    public func close() { rawStream.close() }

    /// The message accumulated so far; `nil` before `message_start` arrived. It is partial until `messageComplete`.
    public var currentMessageSnapshot: ParsedMessage<Output>? {
        snapshot.map { ParsedMessage(message: $0, parsedOutputs: parsedOutputs) }
    }

    /// Whether `message_stop` was received, so that the snapshot is the whole message.
    public var messageComplete: Bool { rawStream.receivedEndEvent }

    /// Waits until the stream has been read to completion and returns the accumulated message.
    ///
    /// It never returns a partial message: a stream that was cancelled (its task, or `close()`) throws
    /// `CancellationError`, and one that ended before `message_stop` throws `StreamEndedEarlyError`.
    public func getFinalMessage() async throws -> ParsedMessage<Output> {
        try await untilDone()
        guard let message = currentMessageSnapshot else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
        guard messageComplete else { throw StreamEndedEarlyError(response: response) }
        return message
    }

    /// Returns all `text` content blocks concatenated together. Throws when the API returned no
    /// `text` content block.
    public func getFinalText() async throws -> String {
        let message = try await getFinalMessage()
        var texts: [String] = []
        for block in message.content { if case .text(let t) = block { texts.append(t.text) } }
        if texts.isEmpty {
            let types = message.content.map { (try? JSONValue.from($0))?["type"]?.stringValue ?? "unknown" }
            throw AnthropicError(
                ".get_final_text() can only be called when the API returns a `text` content block.\nThe API returned \(types.joined(separator: ",")) content block type(s) that you can access by calling get_final_message().content")
        }
        return texts.joined()
    }

    /// Waits until the stream has been consumed.
    public func untilDone() async throws {
        while try await nextEvent() != nil {}
    }

    /// Just the text deltas of the stream. It ends, and throws, as the stream does.
    public var textStream: MessageTextStream {
        MessageTextStream { [self] in
            while let event = try await self.nextEvent() {
                if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta { return d.text }
            }
            return nil
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let stream: MessageStream<Output>
        public mutating func next() async throws -> ParsedMessageStreamEvent? { try await stream.nextEvent() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(stream: self) }

    func nextEvent() async throws -> ParsedMessageStreamEvent? {
        while true {
            if !pending.isEmpty { return pending.removeFirst() }
            if done { return nil }
            if rawIterator == nil { rawIterator = rawStream.makeAsyncIterator() }
            guard let event = try await rawIterator!.next() else {
                done = true
                return nil
            }
            if case .unknown(let json) = event, isUndecodedMessageEvent(json) {
                // The snapshot takes only part of it (`accumulateUndecodedEvent`), so it is not the Message the events make.
                withholdMessageSnapshot(rawStream)
            }
            if snapshot == nil, !startsMessage(event) { return .raw(event) }
            do {
                snapshot = try accumulateEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs)
                if case .contentBlockStop(let e) = event, let parser, let message = snapshot, message.content.indices.contains(e.index),
                   case .text(let t) = message.content[e.index]
                {
                    parsedOutputs[e.index] = try parser(t.text)
                }
            } catch {
                // The Message cannot be built past this event, so the stream ends here and every later read (and
                // `getFinalMessage()`) throws this, as `JSONMessageStream` does.
                withholdMessageSnapshot(rawStream)
                rawStream.fail(error)
                throw error
            }
            guard let message = snapshot else { continue }
            pending.append(contentsOf: buildEvents(event, snapshot: message))
        }
    }
}

/// The content block types whose `input` is streamed as `input_json_delta` (`TRACKS_TOOL_INPUT`).
let tracksToolInput: Set<String> = ["tool_use", "server_tool_use"]

/// Applies one raw event to the accumulated message (`lib/streaming/_messages.accumulate_event`).
public func accumulateEvent(_ event: RawMessageStreamEvent, snapshot current: Message?, jsonBufs: inout [Int: String]) throws -> Message {
    guard var snapshot = current else {
        if case .messageStart(let e) = event { return e.message }
        if case .unknown(let json) = event, startsMessage(event) {
            return try messageOfUndecodedStart(json, as: RawMessageStartEvent.self).message
        }
        throw AnthropicError("Unexpected event order, got \(rawEventType(event)) before \"message_start\"")
    }
    switch event {
    case .contentBlockStart(let e):
        snapshot.content.append(try convertJSON(e.contentBlock, to: ContentBlock.self))
    case .contentBlockDelta(let e):
        guard snapshot.content.indices.contains(e.index) else {
            throw AnthropicError("Unexpected content_block_delta for unknown content block index \(e.index)")
        }
        var content = snapshot.content[e.index]
        if case .unknown(let held) = content {
            // A block whose start did not decode takes its deltas as JSON.
            snapshot.content[e.index] = try blockApplyingDelta(try JSONValue.from(e.delta), to: content, held: held, index: e.index,
                                                               jsonBufs: &jsonBufs, mode: .on, unknown: ContentBlock.unknown)
            return snapshot
        }
        switch e.delta {
        case .textDelta(let d):
            if case .text(var b) = content {
                b.text += d.text
                content = .text(b)
            }
        case .inputJsonDelta(let d):
            switch content {
            case .toolUse(var b):
                if let input = try accumulateToolInput(&jsonBufs, index: e.index, partialJSON: d.partialJson, mode: .on) { b.input = input }
                content = .toolUse(b)
            case .serverToolUse(var b):
                if let input = try accumulateToolInput(&jsonBufs, index: e.index, partialJSON: d.partialJson, mode: .on) { b.input = input }
                content = .serverToolUse(b)
            default: break
            }
        case .citationsDelta(let d):
            if case .text(var b) = content {
                let citation = try convertJSON(d.citation, to: TextCitation.self)
                if b.citations?.isEmpty ?? true { b.citations = [citation] } else { b.citations!.append(citation) }
                content = .text(b)
            }
        case .thinkingDelta(let d):
            if case .thinking(var b) = content {
                b.thinking += d.thinking
                content = .thinking(b)
            }
        case .signatureDelta(let d):
            if case .thinking(var b) = content {
                b.signature = d.signature
                content = .thinking(b)
            }
        case .unknown:
            break
        }
        snapshot.content[e.index] = content
    case .messageDelta(let e):
        snapshot.stopReason = e.delta.stopReason
        snapshot.stopSequence = e.delta.stopSequence
        snapshot.stopDetails = e.delta.stopDetails
        if let container = e.delta.container { snapshot.container = container }
        snapshot.usage.outputTokens = e.usage.outputTokens
        // Usage counts on a message_delta are cumulative totals, so they overwrite rather than add;
        // optional ones are omitted when not applicable, in which case the message_start value survives.
        if let v = e.usage.inputTokens { snapshot.usage.inputTokens = v }
        if let v = e.usage.cacheCreationInputTokens { snapshot.usage.cacheCreationInputTokens = v }
        if let v = e.usage.cacheReadInputTokens { snapshot.usage.cacheReadInputTokens = v }
        if let v = e.usage.serverToolUse { snapshot.usage.serverToolUse = v }
        if let v = e.usage.outputTokensDetails { snapshot.usage.outputTokensDetails = v }
    case .unknown(let json):
        try accumulateUndecodedEvent(json, into: &snapshot, jsonBufs: &jsonBufs)
    case .messageStart, .messageStop, .contentBlockStop:
        break
    }
    return snapshot
}

/// Applies an event that a stream handed out undecoded, losing only what does not decode; see
/// `accumulateUndecodedBetaEvent`.
func accumulateUndecodedEvent(_ json: JSONValue, into snapshot: inout Message, jsonBufs: inout [Int: String]) throws {
    let type = json["type"]?.stringValue
    guard type == "content_block_start" || type == "content_block_delta" || type == "message_delta" else { return }
    let repairable = type == "message_delta" ? messageDeltaWithRequiredFields(json, outputTokens: snapshot.usage.outputTokens) : json
    if let event = decodeLeavingOutDrift(RawMessageStreamEvent.self, from: repairable) {
        if case .unknown = event {} else {
            snapshot = try accumulateEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs)
            return
        }
    }
    switch type {
    case "content_block_start":
        let block = json["content_block"] ?? .null
        snapshot.content.append(decodeLeavingOutDrift(ContentBlock.self, from: block) ?? .unknown(block))
    case "content_block_delta":
        guard let index = json["index"]?.intValue, snapshot.content.indices.contains(index), let delta = json["delta"] else { return }
        let block = snapshot.content[index]
        var held: JSONValue?
        if case .unknown(let j) = block { held = j }
        snapshot.content[index] = try blockApplyingDelta(delta, to: block, held: held, index: index, jsonBufs: &jsonBufs, mode: .on,
                                                         unknown: ContentBlock.unknown)
    default:
        break
    }
}

/// Whether `event` is a `message_start`, decoded or not.
func startsMessage(_ event: RawMessageStreamEvent) -> Bool {
    switch event {
    case .messageStart: return true
    case .unknown(let json): return json["type"]?.stringValue == "message_start"
    default: return false
    }
}

/// Appends a tool-input delta to its buffer and parses the buffer so far. Returns `nil` while the
/// buffer is empty.
func accumulateToolInput(_ bufs: inout [Int: String], index: Int, partialJSON: String, mode: PartialJSONMode) throws -> [String: JSONValue]? {
    let buf = (bufs[index] ?? "") + partialJSON
    bufs[index] = buf
    if buf.isEmpty { return nil }
    let parsed: JSONValue
    do {
        parsed = try JSONTextParser.parse(Data(buf.utf8), mode: mode, maxDepth: JSONTextParser.toolInputMaxDepth).jsonValue
    } catch {
        throw toolInputError(error, buf)
    }
    return parsed.objectValue ?? [:]
}

/// The error for a tool input `buf` that does not parse: upstream's, for input that is not JSON, and one that says so
/// for input nested deeper than the parser goes (`PartialJSONError.exceedsNestingLimit`), which is no fault of the model's.
func toolInputError(_ error: any Error, _ buf: String) -> ValueError {
    if let e = error as? PartialJSONError, e.exceedsNestingLimit {
        return ValueError("The tool input nests arrays and objects deeper than the \(JSONTextParser.toolInputMaxDepth) levels this SDK parses. JSON: \(buf)")
    }
    return ValueError("Unable to parse tool parameter JSON from model. Please retry your request or adjust your prompt. Error: \(error). JSON: \(buf)")
}

/// The events to yield for one raw event (`lib/streaming/_messages.build_events`).
public func buildEvents(_ event: RawMessageStreamEvent, snapshot: Message) -> [ParsedMessageStreamEvent] {
    switch event {
    case .messageStart(let e): return [.messageStart(e)]
    case .messageDelta(let e): return [.messageDelta(e)]
    case .messageStop: return [.messageStop(ParsedMessageStopEvent(message: snapshot))]
    case .contentBlockStart(let e): return [.contentBlockStart(e)]
    case .contentBlockDelta(let e):
        var events: [ParsedMessageStreamEvent] = [.contentBlockDelta(e)]
        guard snapshot.content.indices.contains(e.index) else { return events }
        let block = snapshot.content[e.index]
        switch (e.delta, block) {
        case (.textDelta(let d), .text(let b)):
            events.append(.text(TextEvent(text: d.text, snapshot: b.text)))
        case (.inputJsonDelta(let d), .toolUse(let b)):
            events.append(.inputJson(InputJsonEvent(partialJSON: d.partialJson, snapshot: .object(b.input))))
        case (.inputJsonDelta(let d), .serverToolUse(let b)):
            events.append(.inputJson(InputJsonEvent(partialJSON: d.partialJson, snapshot: .object(b.input))))
        case (.citationsDelta(let d), .text(let b)):
            events.append(.citation(CitationEvent(citation: d.citation, snapshot: b.citations ?? [])))
        case (.thinkingDelta(let d), .thinking(let b)):
            events.append(.thinking(ThinkingEvent(thinking: d.thinking, snapshot: b.thinking)))
        case (.signatureDelta, .thinking(let b)):
            events.append(.signature(SignatureEvent(signature: b.signature)))
        default:
            break
        }
        return events
    case .contentBlockStop(let e):
        guard snapshot.content.indices.contains(e.index) else { return [.raw(event)] }
        return [.contentBlockStop(ParsedContentBlockStopEvent(index: e.index, contentBlock: snapshot.content[e.index]))]
    case .unknown:
        return [.raw(event)]
    }
}

/// The text deltas of a Messages stream (`text_stream`): `for try await text in stream.textStream { ... }`.
///
/// It reads the stream it came from, so it ends and throws as that stream does: a read in a cancelled task throws
/// `CancellationError` (an `AsyncThrowingStream(unfolding:)` ends without an error when its task is cancelled).
public struct MessageTextStream: AsyncSequence, Sendable {
    public typealias Element = String
    let produce: @Sendable () async throws -> String?

    init(_ produce: @escaping @Sendable () async throws -> String?) { self.produce = produce }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let produce: @Sendable () async throws -> String?
        public mutating func next() async throws -> String? { try await produce() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(produce: produce) }
}
