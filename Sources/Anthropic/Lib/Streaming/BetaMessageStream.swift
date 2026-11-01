import Foundation

/// A beta Messages stream that accumulates its events into the final message
/// (`lib/streaming/_beta_messages.BetaAsyncMessageStream`). Returned by `client.beta.messages.stream(...)`.
/// See `MessageStream`.
public final class BetaMessageStream<Output: Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = ParsedBetaMessageStreamEvent

    private let rawStream: Stream<BetaRawMessageStreamEvent>
    private let parser: OutputParser<Output>?
    private var rawIterator: Stream<BetaRawMessageStreamEvent>.AsyncIterator?
    private var pending: [ParsedBetaMessageStreamEvent] = []
    private var snapshot: BetaMessage? {
        didSet { tracedMessage?.updateSnapshot(snapshot) }
    }
    private var tracedMessage: StreamedMessage?
    private var parsedOutputs: [Int: Output] = [:]
    private var jsonBufs: [Int: String] = [:]
    private var done = false
    /// Whether `message_stop` was received.
    public private(set) var messageComplete = false
    /// How many `content_block_stop` events were received.
    public private(set) var completedBlocks = 0

    public init(rawStream: Stream<BetaRawMessageStreamEvent>, parser: OutputParser<Output>? = nil) {
        self.rawStream = rawStream
        self.parser = parser
        // The span of the call takes its output content from the Message accumulated here.
        self.tracedMessage = shareMessageSnapshot(rawStream)
    }

    public var response: HTTPResponse { rawStream.response }
    public var requestID: String? { response.headers["request-id"] }
    public var workspaceID: String? { response.headers["anthropic-workspace-id"] }

    public func close() { rawStream.close() }

    public var currentMessageSnapshot: ParsedBetaMessage<Output>? {
        snapshot.map { ParsedBetaMessage(message: $0, parsedOutputs: parsedOutputs) }
    }

    public func getFinalMessage() async throws -> ParsedBetaMessage<Output> {
        try await untilDone()
        guard let message = currentMessageSnapshot else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
        return message
    }

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

    public func untilDone() async throws {
        while try await nextEvent() != nil {}
    }

    public var textStream: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream(unfolding: { [self] in
            while let event = try await self.nextEvent() {
                if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta { return d.text }
            }
            return nil
        })
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let stream: BetaMessageStream<Output>
        public mutating func next() async throws -> ParsedBetaMessageStreamEvent? { try await stream.nextEvent() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(stream: self) }

    func nextEvent() async throws -> ParsedBetaMessageStreamEvent? {
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
                snapshot = try accumulateBetaEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs, requestHeaders: response.request.headers)
            } catch {
                withholdMessageSnapshot(rawStream)
                throw error
            }
            guard let message = snapshot else { continue }
            if case .contentBlockStop(let e) = event {
                completedBlocks += 1
                if let parser, message.content.indices.contains(e.index), case .text(let t) = message.content[e.index] {
                    parsedOutputs[e.index] = try parser(t.text)
                }
            } else if case .messageStop = event {
                messageComplete = true
            }
            pending.append(contentsOf: buildBetaEvents(event, snapshot: message))
        }
    }
}

/// Applies one raw event to the accumulated message (`lib/streaming/_beta_messages.accumulate_event`).
///
/// `requestHeaders` are the headers the stream was requested with: with the
/// `fine-grained-tool-streaming-2025-05-14` beta, incomplete strings in tool inputs are kept.
public func accumulateBetaEvent(_ event: BetaRawMessageStreamEvent, snapshot current: BetaMessage?, jsonBufs: inout [Int: String],
                                requestHeaders: HTTPHeaders?) throws -> BetaMessage
{
    guard var snapshot = current else {
        if case .messageStart(let e) = event { return e.message }
        throw AnthropicError("Unexpected event order, got \(betaRawEventType(event)) before \"message_start\"")
    }
    switch event {
    case .contentBlockStart(let e):
        snapshot.content.append(try convertJSON(e.contentBlock, to: BetaContentBlock.self))
        if case .fallback(let block) = e.contentBlock {
            // the final hop's fallback block names the model that served the response
            snapshot.model = block.to.model
        }
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
            let anthropicBeta = requestHeaders?["anthropic-beta"] ?? ""
            let mode: PartialJSONMode = anthropicBeta.contains("fine-grained-tool-streaming-2025-05-14") ? .trailingStrings : .on
            switch content {
            case .toolUse(var b):
                if let input = try accumulateToolInput(&jsonBufs, index: e.index, partialJSON: d.partialJson, mode: mode) { b.input = input }
                content = .toolUse(b)
            case .serverToolUse(var b):
                if let input = try accumulateToolInput(&jsonBufs, index: e.index, partialJSON: d.partialJson, mode: mode) { b.input = input }
                content = .serverToolUse(b)
            case .mcpToolUse(var b):
                if let input = try accumulateToolInput(&jsonBufs, index: e.index, partialJSON: d.partialJson, mode: mode) { b.input = input }
                content = .mcpToolUse(b)
            default: break
            }
        case .citationsDelta(let d):
            if case .text(var b) = content {
                let citation = try convertJSON(d.citation, to: BetaTextCitation.self)
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
        case .compactionDelta(let d):
            if case .compaction(var b) = content {
                b.content = d.content
                b.encryptedContent = d.encryptedContent
                content = .compaction(b)
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
        if let cm = e.contextManagement { snapshot.contextManagement = cm }
        // only sent on `message_delta` after a mid-stream fallback, in which case it replaces the
        // `message_start` value; otherwise that value must survive
        if let it = e.inputTransformations { snapshot.inputTransformations = it }
        snapshot.usage.outputTokens = e.usage.outputTokens
        if let v = e.usage.inputTokens { snapshot.usage.inputTokens = v }
        if let v = e.usage.cacheCreationInputTokens { snapshot.usage.cacheCreationInputTokens = v }
        if let v = e.usage.cacheReadInputTokens { snapshot.usage.cacheReadInputTokens = v }
        if let v = e.usage.serverToolUse { snapshot.usage.serverToolUse = v }
        if let v = e.usage.outputTokensDetails { snapshot.usage.outputTokensDetails = v }
        if let v = e.usage.iterations { snapshot.usage.iterations = v }
        if let v = e.usage.fallbackCredit { snapshot.usage.fallbackCredit = v }
    case .messageStart, .messageStop, .contentBlockStop, .unknown:
        break
    }
    return snapshot
}

/// The events to yield for one raw event (`lib/streaming/_beta_messages.build_events`).
public func buildBetaEvents(_ event: BetaRawMessageStreamEvent, snapshot: BetaMessage) -> [ParsedBetaMessageStreamEvent] {
    switch event {
    case .messageStart(let e): return [.messageStart(e)]
    case .messageDelta(let e): return [.messageDelta(e)]
    case .messageStop: return [.messageStop(ParsedBetaMessageStopEvent(message: snapshot))]
    case .contentBlockStart(let e): return [.contentBlockStart(e)]
    case .contentBlockDelta(let e):
        var events: [ParsedBetaMessageStreamEvent] = [.contentBlockDelta(e)]
        guard snapshot.content.indices.contains(e.index) else { return events }
        let block = snapshot.content[e.index]
        switch (e.delta, block) {
        case (.textDelta(let d), .text(let b)):
            events.append(.text(TextEvent(text: d.text, snapshot: b.text)))
        case (.inputJsonDelta(let d), .toolUse(let b)):
            events.append(.inputJson(InputJsonEvent(partialJSON: d.partialJson, snapshot: .object(b.input))))
        case (.inputJsonDelta(let d), .serverToolUse(let b)):
            events.append(.inputJson(InputJsonEvent(partialJSON: d.partialJson, snapshot: .object(b.input))))
        case (.inputJsonDelta(let d), .mcpToolUse(let b)):
            events.append(.inputJson(InputJsonEvent(partialJSON: d.partialJson, snapshot: .object(b.input))))
        case (.citationsDelta(let d), .text(let b)):
            events.append(.citation(BetaCitationEvent(citation: d.citation, snapshot: b.citations ?? [])))
        case (.thinkingDelta(let d), .thinking(let b)):
            events.append(.thinking(ThinkingEvent(thinking: d.thinking, snapshot: b.thinking)))
        case (.signatureDelta, .thinking(let b)):
            events.append(.signature(SignatureEvent(signature: b.signature)))
        case (.compactionDelta, .compaction(let b)):
            events.append(.compaction(BetaCompactionEvent(content: b.content, encryptedContent: b.encryptedContent)))
        default:
            break
        }
        return events
    case .contentBlockStop(let e):
        guard snapshot.content.indices.contains(e.index) else { return [.raw(event)] }
        return [.contentBlockStop(ParsedBetaContentBlockStopEvent(index: e.index, contentBlock: snapshot.content[e.index]))]
    case .unknown:
        return [.raw(event)]
    }
}
