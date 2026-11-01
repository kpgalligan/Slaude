// Transformed from `anthropic.types.beta.beta_managed_agents_memory_store_archived_deployment_paused_reason_error` (beta_managed_agents_memory_store_archived_deployment_paused_reason_error.py).

import Foundation

/// A memory store referenced by the deployment is archived.
public struct BetaManagedAgentsMemoryStoreArchivedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "memory_store_archived_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
