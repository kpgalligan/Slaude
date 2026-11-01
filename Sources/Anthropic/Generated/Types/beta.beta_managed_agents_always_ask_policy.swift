// Transformed from `anthropic.types.beta.beta_managed_agents_always_ask_policy` (beta_managed_agents_always_ask_policy.py).

import Foundation

/// Tool calls require user confirmation before execution.
public struct BetaManagedAgentsAlwaysAskPolicy: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_ask") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
