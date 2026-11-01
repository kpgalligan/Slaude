// Transformed from `anthropic.types.beta.beta_managed_agents_deleted_memory_store` (beta_managed_agents_deleted_memory_store.py).

import Foundation

/// Confirmation that a `memory_store` was deleted.
public struct BetaManagedAgentsDeletedMemoryStore: Codable, Hashable, Sendable {
    /// ID of the deleted memory store (a `memstore_...` identifier).
    ///
    /// The store and all its memories and versions are no longer retrievable.
    public var id: String
    public var type: String

    public init(id: String, type: String = "memory_store_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
