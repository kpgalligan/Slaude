// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory_version` (beta_managed_agents_memory_version.py).

import Foundation

/// One entry in a memory's history, recording a single change and who made it.
///
/// Every change to a memory adds one version. Only redaction can change a version after that. Versions belong to the memory store and stay after the memory is deleted. Each version is retained for at least the version retention period after it was written, unless the store itself is deleted.
///
/// Retrieving a redacted version succeeds, with `content`, `path`, `content_size_bytes`, and `content_sha256` set to `null`. Check `redacted_at` to find out whether a version was redacted.
///
/// See the [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#audit-memory-changes) to learn more about memory versions.
public struct BetaManagedAgentsMemoryVersion: Codable, Hashable, Sendable {
    /// Unique identifier for this version (a `memver_...` value).
    public var id: String
    /// When this version was written, in RFC 3339 format.
    public var createdAt: Date
    /// The ID of the memory that this version belongs to (`mem_...`).
    ///
    /// The ID stays valid after the memory is deleted. Pass it as `memory_id` to
    /// [List Memory Versions](https://platform.claude.com/docs/en/api/beta/memory_stores/memory_versions/list)
    /// to get the memory's retained versions, including its `deleted` version while the
    /// lineage is retained.
    public var memoryID: String
    /// ID of the memory store this version belongs to (a `memstore_...` value).
    public var memoryStoreID: String
    /// The kind of mutation this version records: `created`, `modified`, or `deleted`.
    public var operation: BetaManagedAgentsMemoryVersionOperation
    public var type: String
    /// The memory's UTF-8 text content as of this version.
    ///
    /// `null` when `view=basic`, when `operation` is `deleted`, or when `redacted_at`
    /// is set.
    public var content: String?
    /// Lowercase hex SHA-256 digest of `content` as of this version (64 characters).
    ///
    /// `null` when `redacted_at` is set or `operation` is `deleted`. Populated
    /// regardless of `view` otherwise.
    public var contentSha256: String?
    /// Size of `content` in bytes as of this version.
    ///
    /// `null` when `redacted_at` is set or `operation` is `deleted`. Populated
    /// regardless of `view` otherwise.
    public var contentSizeBytes: Int?
    /// Who made this change to the memory, or `null` if the author wasn't recorded.
    ///
    /// Redacting the version doesn't change this field. A `session_actor` here is an
    /// agent that wrote through the store's mounted filesystem at `/mnt/memory/`. The
    /// version doesn't record the API key that created that session. So the author in
    /// `created_by` is who made the change, not who is ultimately responsible for it.
    ///
    /// You can
    /// [retrieve the session](https://platform.claude.com/docs/en/api/beta/sessions/retrieve)
    /// to learn more about where the change came from.
    public var createdBy: BetaManagedAgentsActor?
    /// The memory's path at the time of this write.
    ///
    /// `null` if and only if `redacted_at` is set.
    public var path: String?
    /// When the version was redacted, in RFC 3339, or `null` if it hasn't been.
    ///
    /// When set, `content`, `path`, `content_size_bytes`, and `content_sha256` are
    /// `null`.
    ///
    /// See the
    /// [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#redact-a-version)
    /// to learn more about redaction.
    public var redactedAt: Date?
    /// Who redacted this version, or `null` if it has not been redacted.
    ///
    /// In practice always an `api_actor`, `user_actor`, or `service_account_actor`
    /// (agents do not have a redact capability).
    public var redactedBy: BetaManagedAgentsActor?

    public init(id: String, createdAt: Date, memoryID: String, memoryStoreID: String, operation: BetaManagedAgentsMemoryVersionOperation, type: String = "memory_version", content: String? = nil, contentSha256: String? = nil, contentSizeBytes: Int? = nil, createdBy: BetaManagedAgentsActor? = nil, path: String? = nil, redactedAt: Date? = nil, redactedBy: BetaManagedAgentsActor? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.memoryID = memoryID
        self.memoryStoreID = memoryStoreID
        self.operation = operation
        self.type = type
        self.content = content
        self.contentSha256 = contentSha256
        self.contentSizeBytes = contentSizeBytes
        self.createdBy = createdBy
        self.path = path
        self.redactedAt = redactedAt
        self.redactedBy = redactedBy
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case memoryID = "memory_id"
        case memoryStoreID = "memory_store_id"
        case operation
        case type
        case content
        case contentSha256 = "content_sha256"
        case contentSizeBytes = "content_size_bytes"
        case createdBy = "created_by"
        case path
        case redactedAt = "redacted_at"
        case redactedBy = "redacted_by"
    }
}
