// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_unrestricted_credential_networking_params` (beta_managed_agents_unrestricted_credential_networking_params.py).

import Foundation

/// Substitute the secret on any host the session's Environment network policy permits egress to. The Environment's network policy is the only boundary on where the secret can reach.
public struct BetaManagedAgentsUnrestrictedCredentialNetworkingParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unrestricted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
