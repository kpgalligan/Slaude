// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_inline_agents_enabled` (beta_managed_agents_multiagent_inline_agents_enabled.py).

import Foundation

/// The agent can define inline agents.
public struct BetaManagedAgentsMultiagentInlineAgentsEnabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
