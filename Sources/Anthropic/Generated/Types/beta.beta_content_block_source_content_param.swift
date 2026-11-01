// Transformed from `anthropic.types.beta.beta_content_block_source_content_param` (beta_content_block_source_content_param.py).

import Foundation

public indirect enum BetaContentBlockSourceContentParam: Codable, Hashable, Sendable {
    case text(BetaTextBlockParam)
    case image(BetaImageBlockParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text": self = .text(try BetaTextBlockParam(from: decoder))
        case "image": self = .image(try BetaImageBlockParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let v): try v.encode(to: encoder)
        case .image(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
