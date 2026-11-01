// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_credential_networking_params` (beta_managed_agents_credential_networking_params.py).

import Foundation

public indirect enum BetaManagedAgentsCredentialNetworkingParams: Codable, Hashable, Sendable {
    case unrestricted(BetaManagedAgentsUnrestrictedCredentialNetworkingParams)
    case limited(BetaManagedAgentsLimitedCredentialNetworkingParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "unrestricted": self = .unrestricted(try BetaManagedAgentsUnrestrictedCredentialNetworkingParams(from: decoder))
        case "limited": self = .limited(try BetaManagedAgentsLimitedCredentialNetworkingParams(from: decoder))
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
