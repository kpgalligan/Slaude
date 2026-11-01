// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_post_param` (beta_managed_agents_token_endpoint_auth_post_param.py).

import Foundation

/// Token endpoint uses POST body authentication with client credentials.
public struct BetaManagedAgentsTokenEndpointAuthPostParam: Codable, Hashable, Sendable {
    /// The OAuth client secret, sent to `token_endpoint` in the POST body.
    public var clientSecret: String
    public var type: String

    public init(clientSecret: String, type: String = "client_secret_post") {
        self.clientSecret = clientSecret
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case type
    }
}
