// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_workflows_disabled` (beta_managed_agents_multiagent_workflows_disabled.py).

import Foundation

/// The agent cannot start workflow runs.
public struct BetaManagedAgentsMultiagentWorkflowsDisabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
