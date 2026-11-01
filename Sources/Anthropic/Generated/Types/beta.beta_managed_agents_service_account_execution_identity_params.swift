// Transformed from `anthropic.types.beta.beta_managed_agents_service_account_execution_identity_params` (beta_managed_agents_service_account_execution_identity_params.py).

import Foundation

/// The Anthropic-managed service account — the default execution principal.
///
/// Carries no identifier.
public struct BetaManagedAgentsServiceAccountExecutionIdentityParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "service_account") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
