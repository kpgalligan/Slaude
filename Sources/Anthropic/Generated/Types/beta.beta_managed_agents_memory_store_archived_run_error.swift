// Transformed from `anthropic.types.beta.beta_managed_agents_memory_store_archived_run_error` (beta_managed_agents_memory_store_archived_run_error.py).

import Foundation

/// A memory store referenced by the deployment is archived.
public struct BetaManagedAgentsMemoryStoreArchivedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "memory_store_archived_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
