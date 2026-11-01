// Transformed from `anthropic.types.beta.beta_raw_content_block_delta` (beta_raw_content_block_delta.py).

import Foundation

public indirect enum BetaRawContentBlockDelta: Codable, Hashable, Sendable {
    case textDelta(BetaTextDelta)
    case inputJsonDelta(BetaInputJSONDelta)
    case citationsDelta(BetaCitationsDelta)
    case thinkingDelta(BetaThinkingDelta)
    case signatureDelta(BetaSignatureDelta)
    case compactionDelta(BetaCompactionContentBlockDelta)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text_delta": self = .textDelta(try BetaTextDelta(from: decoder))
        case "input_json_delta": self = .inputJsonDelta(try BetaInputJSONDelta(from: decoder))
        case "citations_delta": self = .citationsDelta(try BetaCitationsDelta(from: decoder))
        case "thinking_delta": self = .thinkingDelta(try BetaThinkingDelta(from: decoder))
        case "signature_delta": self = .signatureDelta(try BetaSignatureDelta(from: decoder))
        case "compaction_delta": self = .compactionDelta(try BetaCompactionContentBlockDelta(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .textDelta(let v): try v.encode(to: encoder)
        case .inputJsonDelta(let v): try v.encode(to: encoder)
        case .citationsDelta(let v): try v.encode(to: encoder)
        case .thinkingDelta(let v): try v.encode(to: encoder)
        case .signatureDelta(let v): try v.encode(to: encoder)
        case .compactionDelta(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
