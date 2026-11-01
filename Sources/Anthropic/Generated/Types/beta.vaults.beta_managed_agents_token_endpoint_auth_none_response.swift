// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_none_response` (beta_managed_agents_token_endpoint_auth_none_response.py).

import Foundation

/// Token endpoint requires no client authentication.
public struct BetaManagedAgentsTokenEndpointAuthNoneResponse: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
