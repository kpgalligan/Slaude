// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_unrestricted_credential_networking_response` (beta_managed_agents_unrestricted_credential_networking_response.py).

import Foundation

/// The secret is substituted on any host the session's Environment network policy permits egress to.
public struct BetaManagedAgentsUnrestrictedCredentialNetworkingResponse: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unrestricted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
