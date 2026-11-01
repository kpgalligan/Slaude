// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_advisor_disabled_params` (beta_managed_agents_multiagent_advisor_disabled_params.py).

import Foundation

/// The agent has no advisor.
public struct BetaManagedAgentsMultiagentAdvisorDisabledParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
