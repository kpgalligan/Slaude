// Transformed from `anthropic.types.beta.beta_managed_agents_organization_disabled_run_error` (beta_managed_agents_organization_disabled_run_error.py).

import Foundation

/// The deployment's organization is disabled.
public struct BetaManagedAgentsOrganizationDisabledRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "organization_disabled_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
