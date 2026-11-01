// Transformed from `anthropic.types.beta.beta_managed_agents_memory_store` (beta_managed_agents_memory_store.py).

import Foundation

/// A `memory_store`: a named container for agent memories, scoped to a workspace.
///
/// Attach a store to a session via `resources[]` to mount it as a directory the agent can read and write.
public struct BetaManagedAgentsMemoryStore: Codable, Hashable, Sendable {
    /// The unique ID of the memory store (`memstore_...`).
    ///
    /// Use it to attach the store to a session.
    public var id: String
    /// When the memory store was archived, in RFC 3339, or `null` if it hasn't been.
    ///
    /// Archiving can't be undone. An archived store can't be attached to new sessions.
    /// You can't create or update its memories or update the store. You can still read
    /// and delete its memories, redact their versions, and delete the store.
    ///
    /// See the
    /// [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#archive-a-store)
    /// to learn more about archiving.
    public var archivedAt: Date?
    /// When the memory store was created, in RFC 3339.
    public var createdAt: Date
    /// Free-text description of what the store contains, up to 1,024 characters.
    ///
    /// Included in the agent's system prompt when the store is attached, so word it to
    /// be useful to the agent. Empty string when unset.
    public var description: String
    /// Key-value pairs for your own use, such as the end user that the store belongs
    /// to.
    ///
    /// A store has at most 16 pairs. Keys are 1 to 64 characters long and values at
    /// most 512 characters. You can't filter lists by metadata.
    public var metadata: [String: String]
    /// Human-readable name for the store.
    ///
    /// 1–255 characters. The store's mount-path slug under `/mnt/memory/` is derived
    /// from this name.
    public var name: String
    public var type: String
    /// When the memory store was last changed, in RFC 3339.
    ///
    /// Changing its `name`, `description`, or `metadata` updates it. Archiving the
    /// store does too. Changes to the store's memories don't.
    public var updatedAt: Date

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, description: String, metadata: [String: String], name: String, type: String = "memory_store", updatedAt: Date) {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.description = description
        self.metadata = metadata
        self.name = name
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case description
        case metadata
        case name
        case type
        case updatedAt = "updated_at"
    }
}
