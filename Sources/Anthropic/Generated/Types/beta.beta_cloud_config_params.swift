// Transformed from `anthropic.types.beta.beta_cloud_config_params` (beta_cloud_config_params.py).

import Foundation

/// Request params for `cloud` environment configuration.
///
/// Fields default to null; on update, omitted fields preserve the
/// existing value.
public struct BetaCloudConfigParams: Codable, Hashable, Sendable {
    /// Environment type
    public var type: String
    /// Network configuration policy. Omit on update to preserve the existing value.
    public var networking: BetaCloudConfigParams.Networking??
    /// Package manager configuration.
    ///
    /// Under `limited` networking, requires `networking.allow_package_managers` to be
    /// `true`. Omit on update to preserve the existing value.
    public var packages: BetaPackagesParams??

    public init(type: String = "cloud", networking: BetaCloudConfigParams.Networking?? = nil, packages: BetaPackagesParams?? = nil) {
        self.type = type
        self.networking = networking
        self.packages = packages
    }

    enum CodingKeys: String, CodingKey {
        case type
        case networking
        case packages
    }
}

extension BetaCloudConfigParams {

    public indirect enum Networking: Codable, Hashable, Sendable {
        case unrestricted(BetaUnrestrictedNetworkParam)
        case limited(BetaLimitedNetworkParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "unrestricted": self = .unrestricted(try BetaUnrestrictedNetworkParam(from: decoder))
            case "limited": self = .limited(try BetaLimitedNetworkParams(from: decoder))
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
