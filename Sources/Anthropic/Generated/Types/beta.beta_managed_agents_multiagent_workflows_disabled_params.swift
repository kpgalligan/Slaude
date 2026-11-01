// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_workflows_disabled_params` (beta_managed_agents_multiagent_workflows_disabled_params.py).

import Foundation

/// The agent cannot start workflow runs.
public struct BetaManagedAgentsMultiagentWorkflowsDisabledParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
