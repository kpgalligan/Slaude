// Transformed from `anthropic.types.beta.beta_raw_message_stream_event` (beta_raw_message_stream_event.py).

import Foundation

public indirect enum BetaRawMessageStreamEvent: Codable, Hashable, Sendable {
    case messageStart(BetaRawMessageStartEvent)
    case messageDelta(BetaRawMessageDeltaEvent)
    case messageStop(BetaRawMessageStopEvent)
    case contentBlockStart(BetaRawContentBlockStartEvent)
    case contentBlockDelta(BetaRawContentBlockDeltaEvent)
    case contentBlockStop(BetaRawContentBlockStopEvent)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "message_start": self = .messageStart(try BetaRawMessageStartEvent(from: decoder))
        case "message_delta": self = .messageDelta(try BetaRawMessageDeltaEvent(from: decoder))
        case "message_stop": self = .messageStop(try BetaRawMessageStopEvent(from: decoder))
        case "content_block_start": self = .contentBlockStart(try BetaRawContentBlockStartEvent(from: decoder))
        case "content_block_delta": self = .contentBlockDelta(try BetaRawContentBlockDeltaEvent(from: decoder))
        case "content_block_stop": self = .contentBlockStop(try BetaRawContentBlockStopEvent(from: decoder))
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
