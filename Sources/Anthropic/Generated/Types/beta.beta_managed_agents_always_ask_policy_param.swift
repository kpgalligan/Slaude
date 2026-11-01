// Transformed from `anthropic.types.beta.beta_managed_agents_always_ask_policy_param` (beta_managed_agents_always_ask_policy_param.py).

import Foundation

/// Tool calls require user confirmation before execution.
public struct BetaManagedAgentsAlwaysAskPolicyParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_ask") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
