// Transformed from `anthropic.types.beta.beta_managed_agents_service_account_execution_identity` (beta_managed_agents_service_account_execution_identity.py).

import Foundation

/// The Anthropic-managed service account as returned in API responses.
public struct BetaManagedAgentsServiceAccountExecutionIdentity: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "service_account") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
