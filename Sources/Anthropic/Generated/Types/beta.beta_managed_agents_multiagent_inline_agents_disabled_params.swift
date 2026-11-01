// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_inline_agents_disabled_params` (beta_managed_agents_multiagent_inline_agents_disabled_params.py).

import Foundation

/// The agent cannot define inline agents.
public struct BetaManagedAgentsMultiagentInlineAgentsDisabledParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
