// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_token_endpoint_auth_none_param` (beta_managed_agents_token_endpoint_auth_none_param.py).

import Foundation

/// Token endpoint requires no client authentication.
public struct BetaManagedAgentsTokenEndpointAuthNoneParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
