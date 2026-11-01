// Transformed from `anthropic.types.beta.beta_managed_agents_environment_archived_deployment_paused_reason_error` (beta_managed_agents_environment_archived_deployment_paused_reason_error.py).

import Foundation

/// The deployment's environment was archived.
public struct BetaManagedAgentsEnvironmentArchivedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "environment_archived_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
