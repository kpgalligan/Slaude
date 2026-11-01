// Transformed from `anthropic.types.beta.beta_managed_agents_memory_store_resource_param` (beta_managed_agents_memory_store_resource_param.py).

import Foundation

/// Parameters for attaching a memory store to an agent session.
public struct BetaManagedAgentsMemoryStoreResourceParam: Codable, Hashable, Sendable {
    /// The memory store ID (memstore\__...).
    ///
    /// Must belong to the caller's organization and workspace.
    public var memoryStoreId: String
    public var type: String
    /// Access mode for the mounted store.
    ///
    /// Defaults to read_write. read_only mounts the store as a read-only filesystem.
    public var access: Access??
    /// Per-attachment guidance for the agent on how to use this store.
    ///
    /// Rendered into the memory section of the system prompt. Max 4096 chars.
    public var instructions: String??

    public init(memoryStoreId: String, type: String = "memory_store", access: Access?? = nil, instructions: String?? = nil) {
        self.memoryStoreId = memoryStoreId
        self.type = type
        self.access = access
        self.instructions = instructions
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case type
        case access
        case instructions
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
