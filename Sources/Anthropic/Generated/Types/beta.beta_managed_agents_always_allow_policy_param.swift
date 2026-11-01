// Transformed from `anthropic.types.beta.beta_managed_agents_always_allow_policy_param` (beta_managed_agents_always_allow_policy_param.py).

import Foundation

/// Tool calls are automatically approved without user confirmation.
public struct BetaManagedAgentsAlwaysAllowPolicyParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
