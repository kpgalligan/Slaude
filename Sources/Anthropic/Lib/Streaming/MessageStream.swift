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

    /// The message accumulated so far; `nil` before `message_start` arrived.
    public var currentMessageSnapshot: ParsedMessage<Output>? {
        snapshot.map { ParsedMessage(message: $0, parsedOutputs: parsedOutputs) }
    }

    /// Waits until the stream has been read to completion and returns the accumulated message.
    public func getFinalMessage() async throws -> ParsedMessage<Output> {
        try await untilDone()
        guard let message = currentMessageSnapshot else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
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

    /// Just the text deltas of the stream.
    public var textStream: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream(unfolding: { [self] in
            while let event = try await self.nextEvent() {
                if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta { return d.text }
            }
            return nil
        })
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
            if snapshot == nil {
                guard case .messageStart = event else { return .raw(event) }
            }
            do {
                snapshot = try accumulateEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs)
            } catch {
                withholdMessageSnapshot(rawStream)
                throw error
            }
            guard let message = snapshot else { continue }
            if case .contentBlockStop(let e) = event, let parser, message.content.indices.contains(e.index),
               case .text(let t) = message.content[e.index]
            {
                parsedOutputs[e.index] = try parser(t.text)
            }
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
    case .messageStart, .messageStop, .contentBlockStop, .unknown:
        break
    }
    return snapshot
}

/// Appends a tool-input delta to its buffer and parses the buffer so far. Returns `nil` while the
/// buffer is empty.
func accumulateToolInput(_ bufs: inout [Int: String], index: Int, partialJSON: String, mode: PartialJSONMode) throws -> [String: JSONValue]? {
    let buf = (bufs[index] ?? "") + partialJSON
    bufs[index] = buf
    if buf.isEmpty { return nil }
    let parsed: JSONValue
    do {
        parsed = try PartialJSON.parse(buf, mode: mode)
    } catch {
        throw ValueError(
            "Unable to parse tool parameter JSON from model. Please retry your request or adjust your prompt. Error: \(error). JSON: \(buf)")
    }
    return parsed.objectValue ?? [:]
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
