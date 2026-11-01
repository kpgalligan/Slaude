// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory` (beta_managed_agents_memory.py).

import Foundation

/// A text document at a path inside a memory store.
///
/// `content` is `null` when the response uses `view=basic`. `content_size_bytes` and `content_sha256` are always set, so you can detect changes without fetching the content. To retrieve, update, or delete a memory, pass its ID, which stays the same when its path changes.
///
/// See the [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#view-and-edit-memories) to learn more about working with memories.
public struct BetaManagedAgentsMemory: Codable, Hashable, Sendable {
    /// The unique ID of the memory (`mem_...`).
    ///
    /// It stays the same when the memory's path changes.
    ///
    /// To retrieve, update, or delete the memory, pass this ID.
    public var id: String
    /// Lowercase hex SHA-256 digest of the UTF-8 `content` bytes (64 characters).
    ///
    /// The server applies no normalization, so clients can compute the same hash
    /// locally for staleness checks and as the value for a `content_sha256`
    /// precondition on update. Always populated, regardless of `view`.
    public var contentSha256: String
    /// The size of the memory's `content` in UTF-8 bytes.
    ///
    /// It is set regardless of `view`.
    public var contentSizeBytes: Int
    /// When this memory was created, in RFC 3339 format.
    public var createdAt: Date
    /// ID of the memory store this memory belongs to (a `memstore_...` value).
    public var memoryStoreID: String
    /// The ID of the memory version that holds the memory's current content
    /// (`memver_...`).
    ///
    /// Memory versions don't have a flag that marks the latest one. Compare their IDs
    /// with this field instead.
    ///
    /// See the
    /// [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#audit-memory-changes)
    /// to learn more about memory versions.
    public var memoryVersionID: String
    /// Hierarchical path of the memory within the store, e.g.
    ///
    /// `/projects/foo/notes.md`. Always starts with `/`. Paths are case-sensitive and
    /// unique within a store. Maximum 1,024 bytes.
    public var path: String
    public var type: String
    /// When the memory was last changed, in RFC 3339.
    ///
    /// To find out who made the change, look at `created_by` on the memory version that
    /// `memory_version_id` references.
    public var updatedAt: Date
    /// The memory's UTF-8 text content, or `null` when the response uses `view=basic`.
    ///
    /// The maximum size is 100 kB (102,400 bytes).
    public var content: String?

    public init(id: String, contentSha256: String, contentSizeBytes: Int, createdAt: Date, memoryStoreID: String, memoryVersionID: String, path: String, type: String = "memory", updatedAt: Date, content: String? = nil) {
        self.id = id
        self.contentSha256 = contentSha256
        self.contentSizeBytes = contentSizeBytes
        self.createdAt = createdAt
        self.memoryStoreID = memoryStoreID
        self.memoryVersionID = memoryVersionID
        self.path = path
        self.type = type
        self.updatedAt = updatedAt
        self.content = content
    }

    enum CodingKeys: String, CodingKey {
        case id
        case contentSha256 = "content_sha256"
        case contentSizeBytes = "content_size_bytes"
        case createdAt = "created_at"
        case memoryStoreID = "memory_store_id"
        case memoryVersionID = "memory_version_id"
        case path
        case type
        case updatedAt = "updated_at"
        case content
    }
}
