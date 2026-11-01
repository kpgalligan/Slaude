// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_basic_response` (beta_managed_agents_token_endpoint_auth_basic_response.py).

import Foundation

/// Token endpoint uses HTTP Basic authentication with client credentials.
public struct BetaManagedAgentsTokenEndpointAuthBasicResponse: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "client_secret_basic") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
