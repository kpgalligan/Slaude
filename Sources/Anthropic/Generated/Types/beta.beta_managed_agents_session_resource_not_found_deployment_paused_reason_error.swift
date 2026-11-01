// Transformed from `anthropic.types.beta.beta_managed_agents_session_resource_not_found_deployment_paused_reason_error` (beta_managed_agents_session_resource_not_found_deployment_paused_reason_error.py).

import Foundation

/// A referenced resource no longer exists and its kind was not reported.
public struct BetaManagedAgentsSessionResourceNotFoundDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "session_resource_not_found_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
