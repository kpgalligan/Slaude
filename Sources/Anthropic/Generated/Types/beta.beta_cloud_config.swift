// Transformed from `anthropic.types.beta.beta_cloud_config` (beta_cloud_config.py).

import Foundation

/// `cloud` environment configuration.
public struct BetaCloudConfig: Codable, Hashable, Sendable {
    /// Network configuration policy.
    public var networking: BetaCloudConfig.Networking
    /// Package manager configuration.
    public var packages: BetaPackages
    /// Environment type
    public var type: String

    public init(networking: BetaCloudConfig.Networking, packages: BetaPackages, type: String = "cloud") {
        self.networking = networking
        self.packages = packages
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case networking
        case packages
        case type
    }
}

extension BetaCloudConfig {

    public indirect enum Networking: Codable, Hashable, Sendable {
        case unrestricted(BetaUnrestrictedNetwork)
        case limited(BetaLimitedNetwork)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "unrestricted": self = .unrestricted(try BetaUnrestrictedNetwork(from: decoder))
            case "limited": self = .limited(try BetaLimitedNetwork(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .unrestricted(let v): try v.encode(to: encoder)
            case .limited(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
