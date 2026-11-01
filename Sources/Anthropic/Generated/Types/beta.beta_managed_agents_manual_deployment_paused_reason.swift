// Transformed from `anthropic.types.beta.beta_managed_agents_manual_deployment_paused_reason` (beta_managed_agents_manual_deployment_paused_reason.py).

import Foundation

/// The caller invoked the pause endpoint on the deployment.
public struct BetaManagedAgentsManualDeploymentPausedReason: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "manual") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
