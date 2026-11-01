// Transformed from `anthropic.types.content_block_source_content_param` (content_block_source_content_param.py).

import Foundation

public indirect enum ContentBlockSourceContentParam: Codable, Hashable, Sendable {
    case text(TextBlockParam)
    case image(ImageBlockParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text": self = .text(try TextBlockParam(from: decoder))
        case "image": self = .image(try ImageBlockParam(from: decoder))
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
