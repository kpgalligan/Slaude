// Transformed from `anthropic.types.beta.beta_managed_agents_environment_not_found_deployment_paused_reason_error` (beta_managed_agents_environment_not_found_deployment_paused_reason_error.py).

import Foundation

/// The deployment's environment no longer exists.
public struct BetaManagedAgentsEnvironmentNotFoundDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "environment_not_found_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
