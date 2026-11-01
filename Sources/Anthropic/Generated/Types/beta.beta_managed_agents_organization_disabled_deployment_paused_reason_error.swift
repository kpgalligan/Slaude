// Transformed from `anthropic.types.beta.beta_managed_agents_organization_disabled_deployment_paused_reason_error` (beta_managed_agents_organization_disabled_deployment_paused_reason_error.py).

import Foundation

/// The deployment's organization is disabled.
public struct BetaManagedAgentsOrganizationDisabledDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "organization_disabled_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
