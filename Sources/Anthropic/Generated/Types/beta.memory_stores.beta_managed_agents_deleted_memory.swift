// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_deleted_memory` (beta_managed_agents_deleted_memory.py).

import Foundation

/// The confirmation that [Delete a Memory](https://platform.claude.com/docs/en/api/beta/memory_stores/memories/delete) returns.
///
/// Deleting a memory doesn't delete its versions. [List Memory Versions](https://platform.claude.com/docs/en/api/beta/memory_stores/memory_versions/list) returns them while they are retained: each version is kept for at least the version retention period after it was written, unless the store itself is deleted.
///
/// See the [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#audit-memory-changes) to learn more about how long versions are kept.
public struct BetaManagedAgentsDeletedMemory: Codable, Hashable, Sendable {
    /// ID of the deleted memory (a `mem_...` value).
    public var id: String
    public var type: String

    public init(id: String, type: String = "memory_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
