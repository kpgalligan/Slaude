// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_image_block` (beta_managed_agents_image_block.py).

import Foundation

/// Image content specified directly as base64 data or as a reference via a URL.
public struct BetaManagedAgentsImageBlock: Codable, Hashable, Sendable {
    /// The source of the image data.
    public var source: BetaManagedAgentsImageBlock.Source
    public var type: String

    public init(source: BetaManagedAgentsImageBlock.Source, type: String = "image") {
        self.source = source
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case source
        case type
    }
}

extension BetaManagedAgentsImageBlock {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaManagedAgentsBase64ImageSource)
        case url(BetaManagedAgentsURLImageSource)
        case file(BetaManagedAgentsFileImageSource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaManagedAgentsBase64ImageSource(from: decoder))
            case "url": self = .url(try BetaManagedAgentsURLImageSource(from: decoder))
            case "file": self = .file(try BetaManagedAgentsFileImageSource(from: decoder))
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
