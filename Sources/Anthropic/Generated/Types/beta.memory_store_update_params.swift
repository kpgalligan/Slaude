// Transformed from `anthropic.types.beta.memory_store_update_params` (memory_store_update_params.py).

import Foundation

public struct MemoryStoreUpdateParams: Codable, Hashable, Sendable {
    /// New description for the store, up to 1,024 characters.
    ///
    /// Pass an empty string to clear it.
    public var description: String??
    /// Changes to apply to the memory store's metadata.
    ///
    /// Keys you leave out keep their values.
    ///
    /// Set a key to a string to add or replace it, or to `null` to remove it. After the
    /// change, the metadata can hold at most 16 key-value pairs. Keys are 1 to 64
    /// characters long and values at most 512 characters.
    public var metadata: [String: String?]??
    /// The new name of the memory store, 1 to 255 characters long, without control
    /// characters.
    ///
    /// Sessions created after the change use the new name for the store's directory
    /// under `/mnt/memory/`.
    public var name: String??
    /// This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    /// `managed-agents-2026-04-01` in this header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(description: String?? = nil, metadata: [String: String?]?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.description = description
        self.metadata = metadata
        self.name = name
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case description
        case metadata
        case name
        case betas
        case workspaceId = "workspace_id"
    }
}
