// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_basic_param` (beta_managed_agents_token_endpoint_auth_basic_param.py).

import Foundation

/// Token endpoint uses HTTP Basic authentication with client credentials.
public struct BetaManagedAgentsTokenEndpointAuthBasicParam: Codable, Hashable, Sendable {
    /// The OAuth client secret, sent to `token_endpoint` with HTTP Basic
    /// authentication.
    public var clientSecret: String
    public var type: String

    public init(clientSecret: String, type: String = "client_secret_basic") {
        self.clientSecret = clientSecret
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case type
    }
}
