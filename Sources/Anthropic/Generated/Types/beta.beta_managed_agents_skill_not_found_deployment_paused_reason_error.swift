// Transformed from `anthropic.types.beta.beta_managed_agents_skill_not_found_deployment_paused_reason_error` (beta_managed_agents_skill_not_found_deployment_paused_reason_error.py).

import Foundation

/// A skill referenced by the deployment's agent no longer exists.
public struct BetaManagedAgentsSkillNotFoundDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "skill_not_found_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
