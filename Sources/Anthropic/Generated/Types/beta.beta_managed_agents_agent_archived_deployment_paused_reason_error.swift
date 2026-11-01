// Transformed from `anthropic.types.beta.beta_managed_agents_agent_archived_deployment_paused_reason_error` (beta_managed_agents_agent_archived_deployment_paused_reason_error.py).

import Foundation

/// The deployment's agent was archived.
public struct BetaManagedAgentsAgentArchivedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "agent_archived_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
