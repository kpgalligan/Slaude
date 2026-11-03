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
    /// What a tool runner does around the events it hands out (Python wraps `stream._iterator`).
    var hooks: BetaMessageStreamHooks?
    private var hooksEnded = false

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

    /// Waits until the stream has been read to completion and returns the accumulated message. It never returns a
    /// partial message: see `MessageStream.getFinalMessage()`.
    public func getFinalMessage() async throws -> ParsedBetaMessage<Output> {
        try await untilDone()
        guard let message = currentMessageSnapshot else {
            throw AnthropicError("The stream ended before a `message_start` event was received")
        }
        guard messageComplete else { throw StreamEndedEarlyError(response: response) }
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
        let stream: BetaMessageStream<Output>
        public mutating func next() async throws -> ParsedBetaMessageStreamEvent? { try await stream.nextEvent() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(stream: self) }

    func nextEvent() async throws -> ParsedBetaMessageStreamEvent? {
        guard let hooks else { return try await readEvent() }
        let event: ParsedBetaMessageStreamEvent?
        do {
            event = try await readEvent()
        } catch {
            try await endHooks(hooks)
            throw error
        }
        guard let event else {
            try await endHooks(hooks)
            return nil
        }
        try await hooks.willYield?(event)
        return event
    }

    private func endHooks(_ hooks: BetaMessageStreamHooks) async throws {
        if hooksEnded { return }
        hooksEnded = true
        try await hooks.didEnd?()
    }

    private func readEvent() async throws -> ParsedBetaMessageStreamEvent? {
        while true {
            if !pending.isEmpty { return pending.removeFirst() }
            if done { return nil }
            if rawIterator == nil { rawIterator = rawStream.makeAsyncIterator() }
            guard let event = try await rawIterator!.next() else {
                done = true
                return nil
            }
            if case .unknown(let json) = event, isUndecodedMessageEvent(json) {
                // The snapshot takes only part of it (`accumulateUndecodedBetaEvent`), so it is not the Message the
                // events make.
                withholdMessageSnapshot(rawStream)
            }
            if snapshot == nil, !startsBetaMessage(event) { return .raw(event) }
            do {
                snapshot = try accumulateBetaEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs, requestHeaders: response.request.headers)
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
            if case .contentBlockStop = event {
                completedBlocks += 1
            } else if case .messageStop = event {
                messageComplete = true
            }
            pending.append(contentsOf: buildBetaEvents(event, snapshot: message))
        }
    }
}

/// The hooks a tool runner puts around the events of a stream it hands out.
struct BetaMessageStreamHooks: Sendable {
    /// Called with each event once it was read, before it is handed out.
    var willYield: (@Sendable (ParsedBetaMessageStreamEvent) async throws -> Void)?
    /// Called once, when the events run out or reading them fails.
    var didEnd: (@Sendable () async throws -> Void)?
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
        if case .unknown(let json) = event, startsBetaMessage(event) {
            return try messageOfUndecodedStart(json, as: BetaRawMessageStartEvent.self).message
        }
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
        let mode = betaToolInputMode(requestHeaders)
        if case .unknown(let held) = content {
            // A block whose start did not decode takes its deltas as JSON.
            snapshot.content[e.index] = try blockApplyingDelta(try JSONValue.from(e.delta), to: content, held: held, index: e.index,
                                                               jsonBufs: &jsonBufs, mode: mode, unknown: BetaContentBlock.unknown)
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
    case .unknown(let json):
        try accumulateUndecodedBetaEvent(json, into: &snapshot, jsonBufs: &jsonBufs, requestHeaders: requestHeaders)
    case .messageStart, .messageStop, .contentBlockStop:
        break
    }
    return snapshot
}

/// Applies an event that a stream handed out undecoded (`LenientStreamEvent`), an event of a known type whose fields
/// drifted from the schema, losing only what does not decode (`Lib/Streaming/UndecodedEvents.swift`):
///
/// * The event is decoded leaving out its drifted fields, and applied as a typed event. A `message_delta` keeps its
///   stop reason and the counts that decode, whatever else drifted.
/// * A `content_block_start` whose block does not decode even so adds the block as its JSON (`unknown`), and the
///   deltas that follow are applied to that JSON; once it decodes, it is the typed block again.
/// * A `content_block_delta` whose delta does not decode is applied to its block as JSON.
///
/// Other events, and an event of a type this SDK does not know, change nothing.
func accumulateUndecodedBetaEvent(_ json: JSONValue, into snapshot: inout BetaMessage, jsonBufs: inout [Int: String],
                                  requestHeaders: HTTPHeaders?) throws
{
    let type = json["type"]?.stringValue
    guard type == "content_block_start" || type == "content_block_delta" || type == "message_delta" else { return }
    let repairable = type == "message_delta" ? messageDeltaWithRequiredFields(json, outputTokens: snapshot.usage.outputTokens) : json
    if let event = decodeLeavingOutDrift(BetaRawMessageStreamEvent.self, from: repairable) {
        if case .unknown = event {} else {
            snapshot = try accumulateBetaEvent(event, snapshot: snapshot, jsonBufs: &jsonBufs, requestHeaders: requestHeaders)
            return
        }
    }
    switch type {
    case "content_block_start":
        let block = json["content_block"] ?? .null
        snapshot.content.append(decodeLeavingOutDrift(BetaContentBlock.self, from: block) ?? .unknown(block))
        if block["type"]?.stringValue == "fallback", let to = block["to"], let model = try? (to["model"] ?? JSONValue.null).decode(as: Model.self) {
            snapshot.model = model
        }
    case "content_block_delta":
        guard let index = json["index"]?.intValue, snapshot.content.indices.contains(index), let delta = json["delta"] else { return }
        let block = snapshot.content[index]
        var held: JSONValue?
        if case .unknown(let j) = block { held = j }
        snapshot.content[index] = try blockApplyingDelta(delta, to: block, held: held, index: index, jsonBufs: &jsonBufs,
                                                         mode: betaToolInputMode(requestHeaders), unknown: BetaContentBlock.unknown)
    default:
        break
    }
}

/// Whether `event` is a `message_start`, decoded or not.
func startsBetaMessage(_ event: BetaRawMessageStreamEvent) -> Bool {
    switch event {
    case .messageStart: return true
    case .unknown(let json): return json["type"]?.stringValue == "message_start"
    default: return false
    }
}

/// How a beta stream parses tool inputs: with the `fine-grained-tool-streaming-2025-05-14` beta, incomplete strings
/// are kept.
func betaToolInputMode(_ requestHeaders: HTTPHeaders?) -> PartialJSONMode {
    (requestHeaders?["anthropic-beta"] ?? "").contains("fine-grained-tool-streaming-2025-05-14") ? .trailingStrings : .on
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
