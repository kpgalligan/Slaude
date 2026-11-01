// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_memory_store_resource` (beta_managed_agents_memory_store_resource.py).

import Foundation

/// A memory store attached to an agent session.
public struct BetaManagedAgentsMemoryStoreResource: Codable, Hashable, Sendable {
    /// The memory store ID (memstore\__...).
    ///
    /// Must belong to the caller's organization and workspace.
    public var memoryStoreId: String
    public var type: String
    /// Access mode for the mounted store.
    ///
    /// Defaults to `read_write`. `read_only` mounts the store as a read-only
    /// filesystem.
    public var access: Access?
    /// Description of the memory store, snapshotted at attach time.
    ///
    /// Rendered into the agent's system prompt. Empty string when the store has no
    /// description.
    public var description: String?
    /// Per-attachment guidance for the agent on how to use this store.
    ///
    /// Rendered into the memory section of the system prompt. Max 4096 chars.
    public var instructions: String?
    /// Filesystem path where the store is mounted in the session container, e.g.
    ///
    /// /mnt/memory/user-preferences. Derived from the store's name. Output-only.
    public var mountPath: String?
    /// Display name of the memory store, snapshotted at attach time.
    ///
    /// Later edits to the store's name do not propagate to this resource.
    public var name: String?

    public init(memoryStoreId: String, type: String = "memory_store", access: Access? = nil, description: String? = nil, instructions: String? = nil, mountPath: String? = nil, name: String? = nil) {
        self.memoryStoreId = memoryStoreId
        self.type = type
        self.access = access
        self.description = description
        self.instructions = instructions
        self.mountPath = mountPath
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case type
        case access
        case description
        case instructions
        case mountPath = "mount_path"
        case name
    }

    public enum Access: OpenEnum, CaseIterable {
        case readWrite
        case readOnly
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Access] = [.readWrite, .readOnly]

        public init(rawValue: String) {
            switch rawValue {
            case "read_write": self = .readWrite
            case "read_only": self = .readOnly
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .readWrite: return "read_write"
            case .readOnly: return "read_only"
            case .unknown(let value): return value
            }
        }
    }
}
