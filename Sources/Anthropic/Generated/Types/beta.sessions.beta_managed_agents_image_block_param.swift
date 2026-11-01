// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_image_block_param` (beta_managed_agents_image_block_param.py).

import Foundation

/// Image content specified directly as base64 data or as a reference via a URL.
public struct BetaManagedAgentsImageBlockParam: Codable, Hashable, Sendable {
    /// The source of the image data.
    public var source: BetaManagedAgentsImageBlockParam.Source
    public var type: String

    public init(source: BetaManagedAgentsImageBlockParam.Source, type: String = "image") {
        self.source = source
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case source
        case type
    }
}

extension BetaManagedAgentsImageBlockParam {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaManagedAgentsBase64ImageSourceParam)
        case url(BetaManagedAgentsURLImageSourceParam)
        case file(BetaManagedAgentsFileImageSourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaManagedAgentsBase64ImageSourceParam(from: decoder))
            case "url": self = .url(try BetaManagedAgentsURLImageSourceParam(from: decoder))
            case "file": self = .file(try BetaManagedAgentsFileImageSourceParam(from: decoder))
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
