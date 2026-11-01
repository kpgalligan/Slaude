// Transformed from `anthropic.types.beta.beta_managed_agents_vault_archived_deployment_paused_reason_error` (beta_managed_agents_vault_archived_deployment_paused_reason_error.py).

import Foundation

/// A vault referenced by the deployment is archived.
public struct BetaManagedAgentsVaultArchivedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "vault_archived_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
