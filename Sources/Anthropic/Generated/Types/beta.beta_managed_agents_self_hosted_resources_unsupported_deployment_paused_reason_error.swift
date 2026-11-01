// Transformed from `anthropic.types.beta.beta_managed_agents_self_hosted_resources_unsupported_deployment_paused_reason_error` (beta_managed_agents_self_hosted_resources_unsupported_deployment_paused_reason_error.py).

import Foundation

/// The deployment configures resources, but its environment is self-hosted and cannot mount them.
public struct BetaManagedAgentsSelfHostedResourcesUnsupportedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "self_hosted_resources_unsupported_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
