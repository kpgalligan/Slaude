// Transformed from `anthropic.types.beta.beta_managed_agents_error_deployment_paused_reason` (beta_managed_agents_error_deployment_paused_reason.py).

import Foundation

/// A scheduled fire recorded a failed run whose error auto-pauses the deployment.
public struct BetaManagedAgentsErrorDeploymentPausedReason: Codable, Hashable, Sendable {
    /// The failed run's error.
    public var error: BetaManagedAgentsDeploymentPausedReasonError
    public var type: String

    public init(error: BetaManagedAgentsDeploymentPausedReasonError, type: String = "error") {
        self.error = error
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case type
    }
}
