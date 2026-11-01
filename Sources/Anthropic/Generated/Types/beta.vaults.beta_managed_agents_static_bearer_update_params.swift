// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_static_bearer_update_params` (beta_managed_agents_static_bearer_update_params.py).

import Foundation

/// Parameters for updating a static bearer token credential.
///
/// The `mcp_server_url` is immutable.
public struct BetaManagedAgentsStaticBearerUpdateParams: Codable, Hashable, Sendable {
    public var type: String
    /// The new static bearer token to replace the stored one.
    public var token: String??

    public init(type: String = "static_bearer", token: String?? = nil) {
        self.type = type
        self.token = token
    }

    enum CodingKeys: String, CodingKey {
        case type
        case token
    }
}
