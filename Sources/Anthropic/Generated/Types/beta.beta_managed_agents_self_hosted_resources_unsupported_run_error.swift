// Transformed from `anthropic.types.beta.beta_managed_agents_self_hosted_resources_unsupported_run_error` (beta_managed_agents_self_hosted_resources_unsupported_run_error.py).

import Foundation

/// The deployment configures resources, but its environment is self-hosted and cannot mount them.
public struct BetaManagedAgentsSelfHostedResourcesUnsupportedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "self_hosted_resources_unsupported_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
