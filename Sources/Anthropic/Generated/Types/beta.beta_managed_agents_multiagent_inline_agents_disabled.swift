// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_inline_agents_disabled` (beta_managed_agents_multiagent_inline_agents_disabled.py).

import Foundation

/// The agent cannot define inline agents.
public struct BetaManagedAgentsMultiagentInlineAgentsDisabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
