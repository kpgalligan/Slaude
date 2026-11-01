// Transformed from `anthropic.types.beta.beta_image_block_param` (beta_image_block_param.py).

import Foundation

public struct BetaImageBlockParam: Codable, Hashable, Sendable {
    public var source: BetaImageBlockParam.Source
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// Configures the transformations the server applies to this image before the model
    /// observes it. Each key names a condition the server transforms images for; its
    /// value selects the transformation applied. Omitted keys keep their default
    /// behavior, and an empty object is equivalent to omitting the field.
    public var transformations: BetaImageTransformationsParam??

    public init(source: BetaImageBlockParam.Source, type: String = "image", cacheControl: BetaCacheControlEphemeralParam?? = nil, transformations: BetaImageTransformationsParam?? = nil) {
        self.source = source
        self.type = type
        self.cacheControl = cacheControl
        self.transformations = transformations
    }

    enum CodingKeys: String, CodingKey {
        case source
        case type
        case cacheControl = "cache_control"
        case transformations
    }
}

extension BetaImageBlockParam {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaBase64ImageSourceParam)
        case url(BetaURLImageSourceParam)
        case file(BetaFileImageSourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaBase64ImageSourceParam(from: decoder))
            case "url": self = .url(try BetaURLImageSourceParam(from: decoder))
            case "file": self = .file(try BetaFileImageSourceParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .base64(let v): try v.encode(to: encoder)
            case .url(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
