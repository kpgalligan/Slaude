// Transformed from `anthropic.types.raw_message_stream_event` (raw_message_stream_event.py).

import Foundation

public indirect enum RawMessageStreamEvent: Codable, Hashable, Sendable {
    case messageStart(RawMessageStartEvent)
    case messageDelta(RawMessageDeltaEvent)
    case messageStop(RawMessageStopEvent)
    case contentBlockStart(RawContentBlockStartEvent)
    case contentBlockDelta(RawContentBlockDeltaEvent)
    case contentBlockStop(RawContentBlockStopEvent)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "message_start": self = .messageStart(try RawMessageStartEvent(from: decoder))
        case "message_delta": self = .messageDelta(try RawMessageDeltaEvent(from: decoder))
        case "message_stop": self = .messageStop(try RawMessageStopEvent(from: decoder))
        case "content_block_start": self = .contentBlockStart(try RawContentBlockStartEvent(from: decoder))
        case "content_block_delta": self = .contentBlockDelta(try RawContentBlockDeltaEvent(from: decoder))
        case "content_block_stop": self = .contentBlockStop(try RawContentBlockStopEvent(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .messageStart(let v): try v.encode(to: encoder)
        case .messageDelta(let v): try v.encode(to: encoder)
        case .messageStop(let v): try v.encode(to: encoder)
        case .contentBlockStart(let v): try v.encode(to: encoder)
        case .contentBlockDelta(let v): try v.encode(to: encoder)
        case .contentBlockStop(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
