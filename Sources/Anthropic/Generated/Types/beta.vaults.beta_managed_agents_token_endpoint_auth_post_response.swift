// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_post_response` (beta_managed_agents_token_endpoint_auth_post_response.py).

import Foundation

/// Token endpoint uses POST body authentication with client credentials.
public struct BetaManagedAgentsTokenEndpointAuthPostResponse: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "client_secret_post") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
