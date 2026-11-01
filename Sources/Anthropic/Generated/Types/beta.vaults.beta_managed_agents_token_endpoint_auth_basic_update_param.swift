// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_basic_update_param` (beta_managed_agents_token_endpoint_auth_basic_update_param.py).

import Foundation

/// Updated HTTP Basic authentication parameters for the token endpoint.
public struct BetaManagedAgentsTokenEndpointAuthBasicUpdateParam: Codable, Hashable, Sendable {
    public var type: String
    /// A new OAuth client secret to replace the stored one.
    ///
    /// The credential must already use `client_secret_basic` or `client_secret_post`.
    /// It keeps its current `token_endpoint_auth` type, even if the `type` sent with
    /// this secret is the other one.
    public var clientSecret: String??

    public init(type: String = "client_secret_basic", clientSecret: String?? = nil) {
        self.type = type
        self.clientSecret = clientSecret
    }

    enum CodingKeys: String, CodingKey {
        case type
        case clientSecret = "client_secret"
    }
}
