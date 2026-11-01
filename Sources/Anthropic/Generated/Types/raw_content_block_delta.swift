// Transformed from `anthropic.types.raw_content_block_delta` (raw_content_block_delta.py).

import Foundation

public indirect enum RawContentBlockDelta: Codable, Hashable, Sendable {
    case textDelta(TextDelta)
    case inputJsonDelta(InputJSONDelta)
    case citationsDelta(CitationsDelta)
    case thinkingDelta(ThinkingDelta)
    case signatureDelta(SignatureDelta)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text_delta": self = .textDelta(try TextDelta(from: decoder))
        case "input_json_delta": self = .inputJsonDelta(try InputJSONDelta(from: decoder))
        case "citations_delta": self = .citationsDelta(try CitationsDelta(from: decoder))
        case "thinking_delta": self = .thinkingDelta(try ThinkingDelta(from: decoder))
        case "signature_delta": self = .signatureDelta(try SignatureDelta(from: decoder))
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
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
