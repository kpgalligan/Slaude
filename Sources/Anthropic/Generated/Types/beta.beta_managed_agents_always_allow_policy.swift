// Transformed from `anthropic.types.beta.beta_managed_agents_always_allow_policy` (beta_managed_agents_always_allow_policy.py).

import Foundation

/// Tool calls are automatically approved without user confirmation.
public struct BetaManagedAgentsAlwaysAllowPolicy: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
