// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_service_account_actor` (beta_managed_agents_service_account_actor.py).

import Foundation

/// A workload authenticated as a service account, for example via Workload Identity Federation.
public struct BetaManagedAgentsServiceAccountActor: Codable, Hashable, Sendable {
    /// ID of the service account (a `svac_...` value).
    public var serviceAccountId: String
    public var type: String

    public init(serviceAccountId: String, type: String = "service_account_actor") {
        self.serviceAccountId = serviceAccountId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountId = "service_account_id"
        case type
    }
}
