// Transformed from `anthropic.types.beta.beta_managed_agents_vault_not_found_deployment_paused_reason_error` (beta_managed_agents_vault_not_found_deployment_paused_reason_error.py).

import Foundation

/// A vault referenced by the deployment no longer exists.
public struct BetaManagedAgentsVaultNotFoundDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "vault_not_found_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
