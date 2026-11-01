import Foundation

// Port of `lib/streaming/_types.py`.

/// A text delta and the text accumulated so far in its block.
public struct TextEvent: Codable, Hashable, Sendable {
    public var type: String = "text"
    /// The text delta.
    public var text: String
    /// The entire accumulated text.
    public var snapshot: String

    public init(text: String, snapshot: String) {
        self.text = text
        self.snapshot = snapshot
    }

    /// The accumulated text parsed as (possibly incomplete) JSON, keeping a trailing incomplete
    /// string (`parsed_snapshot()`).
    public func parsedSnapshot() throws -> JSONValue { try PartialJSON.parse(snapshot, mode: .trailingStrings) }
}

/// A citation delta and all citations accumulated in its block.
public struct CitationEvent: Codable, Hashable, Sendable {
    public var type: String = "citation"
    /// The new citation.
    public var citation: CitationsDelta.Citation
    /// All of the accumulated citations.
    public var snapshot: [TextCitation]

    public init(citation: CitationsDelta.Citation, snapshot: [TextCitation]) {
        self.citation = citation
        self.snapshot = snapshot
    }
}

/// A thinking delta and the thinking accumulated so far.
public struct ThinkingEvent: Codable, Hashable, Sendable {
    public var type: String = "thinking"
    public var thinking: String
    public var snapshot: String

    public init(thinking: String, snapshot: String) {
        self.thinking = thinking
        self.snapshot = snapshot
    }
}

/// The signature of a thinking block.
public struct SignatureEvent: Codable, Hashable, Sendable {
    public var type: String = "signature"
    public var signature: String

    public init(signature: String) { self.signature = signature }
}

/// A tool-input JSON delta and the input parsed from everything received so far.
public struct InputJsonEvent: Codable, Hashable, Sendable {
    public var type: String = "input_json"
    /// A partial JSON string delta, e.g. `"San Francisco,`.
    public var partialJSON: String
    /// The currently accumulated parsed object, e.g. `["location": "San Francisco, CA"]`.
    public var snapshot: JSONValue

    public init(partialJSON: String, snapshot: JSONValue) {
        self.partialJSON = partialJSON
        self.snapshot = snapshot
    }

    enum CodingKeys: String, CodingKey {
        case type
        case partialJSON = "partial_json"
        case snapshot
    }
}

/// `message_stop`, carrying the accumulated message.
public struct ParsedMessageStopEvent: Codable, Hashable, Sendable {
    public var type: String = "message_stop"
    public var message: Message

    public init(message: Message) { self.message = message }
}

/// `content_block_stop`, carrying the accumulated block.
public struct ParsedContentBlockStopEvent: Codable, Hashable, Sendable {
    public var type: String = "content_block_stop"
    public var index: Int
    public var contentBlock: ContentBlock

    public init(index: Int, contentBlock: ContentBlock) {
        self.index = index
        self.contentBlock = contentBlock
    }

    enum CodingKeys: String, CodingKey {
        case type
        case index
        case contentBlock = "content_block"
    }
}

/// An event yielded by `MessageStream` (`ParsedMessageStreamEvent`): the raw API events, interleaved
/// with helper events derived from the accumulated message.
public enum ParsedMessageStreamEvent: Hashable, Sendable, Encodable {
    case text(TextEvent)
    case citation(CitationEvent)
    case thinking(ThinkingEvent)
    case signature(SignatureEvent)
    case inputJson(InputJsonEvent)
    case messageStart(RawMessageStartEvent)
    case messageDelta(RawMessageDeltaEvent)
    case messageStop(ParsedMessageStopEvent)
    case contentBlockStart(RawContentBlockStartEvent)
    case contentBlockDelta(RawContentBlockDeltaEvent)
    case contentBlockStop(ParsedContentBlockStopEvent)
    /// An API event passed through as received: an event type this SDK doesn't know, or an event
    /// that arrived before `message_start`.
    case raw(RawMessageStreamEvent)

    /// The event's `type` (`"text"`, `"message_start"`, ...).
    public var type: String {
        switch self {
        case .text(let e): return e.type
        case .citation(let e): return e.type
        case .thinking(let e): return e.type
        case .signature(let e): return e.type
        case .inputJson(let e): return e.type
        case .messageStart(let e): return e.type
        case .messageDelta(let e): return e.type
        case .messageStop(let e): return e.type
        case .contentBlockStart(let e): return e.type
        case .contentBlockDelta(let e): return e.type
        case .contentBlockStop(let e): return e.type
        case .raw(let e): return rawEventType(e)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let e): try e.encode(to: encoder)
        case .citation(let e): try e.encode(to: encoder)
        case .thinking(let e): try e.encode(to: encoder)
        case .signature(let e): try e.encode(to: encoder)
        case .inputJson(let e): try e.encode(to: encoder)
        case .messageStart(let e): try e.encode(to: encoder)
        case .messageDelta(let e): try e.encode(to: encoder)
        case .messageStop(let e): try e.encode(to: encoder)
        case .contentBlockStart(let e): try e.encode(to: encoder)
        case .contentBlockDelta(let e): try e.encode(to: encoder)
        case .contentBlockStop(let e): try e.encode(to: encoder)
        case .raw(let e): try e.encode(to: encoder)
        }
    }
}

func rawEventType(_ e: RawMessageStreamEvent) -> String {
    switch e {
    case .messageStart(let v): return v.type
    case .messageDelta(let v): return v.type
    case .messageStop(let v): return v.type
    case .contentBlockStart(let v): return v.type
    case .contentBlockDelta(let v): return v.type
    case .contentBlockStop(let v): return v.type
    case .unknown(let v): return v["type"]?.stringValue ?? ""
    }
}

// Port of `lib/streaming/_beta_types.py`.

/// A text delta and the text accumulated so far in its block.
public typealias BetaTextEvent = TextEvent
/// A thinking delta and the thinking accumulated so far.
public typealias BetaThinkingEvent = ThinkingEvent
/// The signature of a thinking block.
public typealias BetaSignatureEvent = SignatureEvent
/// A tool-input JSON delta and the input parsed from everything received so far.
public typealias BetaInputJsonEvent = InputJsonEvent

/// A citation delta and all citations accumulated in its block.
public struct BetaCitationEvent: Codable, Hashable, Sendable {
    public var type: String = "citation"
    public var citation: BetaCitationsDelta.Citation
    public var snapshot: [BetaTextCitation]

    public init(citation: BetaCitationsDelta.Citation, snapshot: [BetaTextCitation]) {
        self.citation = citation
        self.snapshot = snapshot
    }
}

/// A compaction block's content.
public struct BetaCompactionEvent: Codable, Hashable, Sendable {
    public var type: String = "compaction"
    /// The compaction content.
    public var content: String?
    /// Opaque metadata from prior compaction, to be round-tripped verbatim.
    public var encryptedContent: String?

    public init(content: String?, encryptedContent: String?) {
        self.content = content
        self.encryptedContent = encryptedContent
    }

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case encryptedContent = "encrypted_content"
    }
}

/// `message_stop`, carrying the accumulated message.
public struct ParsedBetaMessageStopEvent: Codable, Hashable, Sendable {
    public var type: String = "message_stop"
    public var message: BetaMessage

    public init(message: BetaMessage) { self.message = message }
}

/// `content_block_stop`, carrying the accumulated block.
public struct ParsedBetaContentBlockStopEvent: Codable, Hashable, Sendable {
    public var type: String = "content_block_stop"
    public var index: Int
    public var contentBlock: BetaContentBlock

    public init(index: Int, contentBlock: BetaContentBlock) {
        self.index = index
        self.contentBlock = contentBlock
    }

    enum CodingKeys: String, CodingKey {
        case type
        case index
        case contentBlock = "content_block"
    }
}

/// An event yielded by `BetaMessageStream` (`ParsedBetaMessageStreamEvent`).
public enum ParsedBetaMessageStreamEvent: Hashable, Sendable, Encodable {
    case text(BetaTextEvent)
    case citation(BetaCitationEvent)
    case thinking(BetaThinkingEvent)
    case signature(BetaSignatureEvent)
    case inputJson(BetaInputJsonEvent)
    case compaction(BetaCompactionEvent)
    case messageStart(BetaRawMessageStartEvent)
    case messageDelta(BetaRawMessageDeltaEvent)
    case messageStop(ParsedBetaMessageStopEvent)
    case contentBlockStart(BetaRawContentBlockStartEvent)
    case contentBlockDelta(BetaRawContentBlockDeltaEvent)
    case contentBlockStop(ParsedBetaContentBlockStopEvent)
    /// An API event passed through as received: an event type this SDK doesn't know, or an event
    /// that arrived before `message_start`.
    case raw(BetaRawMessageStreamEvent)

    public var type: String {
        switch self {
        case .text(let e): return e.type
        case .citation(let e): return e.type
        case .thinking(let e): return e.type
        case .signature(let e): return e.type
        case .inputJson(let e): return e.type
        case .compaction(let e): return e.type
        case .messageStart(let e): return e.type
        case .messageDelta(let e): return e.type
        case .messageStop(let e): return e.type
        case .contentBlockStart(let e): return e.type
        case .contentBlockDelta(let e): return e.type
        case .contentBlockStop(let e): return e.type
        case .raw(let e): return betaRawEventType(e)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let e): try e.encode(to: encoder)
        case .citation(let e): try e.encode(to: encoder)
        case .thinking(let e): try e.encode(to: encoder)
        case .signature(let e): try e.encode(to: encoder)
        case .inputJson(let e): try e.encode(to: encoder)
        case .compaction(let e): try e.encode(to: encoder)
        case .messageStart(let e): try e.encode(to: encoder)
        case .messageDelta(let e): try e.encode(to: encoder)
        case .messageStop(let e): try e.encode(to: encoder)
        case .contentBlockStart(let e): try e.encode(to: encoder)
        case .contentBlockDelta(let e): try e.encode(to: encoder)
        case .contentBlockStop(let e): try e.encode(to: encoder)
        case .raw(let e): try e.encode(to: encoder)
        }
    }
}

func betaRawEventType(_ e: BetaRawMessageStreamEvent) -> String {
    switch e {
    case .messageStart(let v): return v.type
    case .messageDelta(let v): return v.type
    case .messageStop(let v): return v.type
    case .contentBlockStart(let v): return v.type
    case .contentBlockDelta(let v): return v.type
    case .contentBlockStop(let v): return v.type
    case .unknown(let v): return v["type"]?.stringValue ?? ""
    }
}

/// Converts between two generated types with the same wire shape (`construct_type(type_=..., value=x.to_dict())`).
func convertJSON<T: Decodable, U: Encodable>(_ value: U, to type: T.Type = T.self) throws -> T {
    try JSONValue.from(value).decode(as: T.self)
}
