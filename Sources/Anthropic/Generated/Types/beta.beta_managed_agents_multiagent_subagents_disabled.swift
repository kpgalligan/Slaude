// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_subagents_disabled` (beta_managed_agents_multiagent_subagents_disabled.py).

import Foundation

/// The agent cannot spawn session threads.
public struct BetaManagedAgentsMultiagentSubagentsDisabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
