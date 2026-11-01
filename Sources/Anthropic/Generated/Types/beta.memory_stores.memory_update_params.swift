// Transformed from `anthropic.types.beta.memory_stores.memory_update_params` (memory_update_params.py).

import Foundation

public struct MemoryUpdateParams: Codable, Hashable, Sendable {
    /// The ID of the memory store that holds the memory (`memstore_...`).
    public var memoryStoreID: String
    /// Whether a `memory` or `memory_version` in the response includes its `content`.
    ///
    /// Defaults to `full` on retrieve operations and to `basic` on list, create, and
    /// update operations.
    ///
    /// With `full`, list operations return at most 20 items per page.
    public var view: BetaManagedAgentsMemoryView?
    /// New UTF-8 text content for the memory.
    ///
    /// Maximum 100 kB (102,400 bytes). Omit to leave the content unchanged (e.g., for a
    /// rename-only update).
    public var content: String??
    /// The new path of the memory, which renames it. Omit it to keep the current path.
    ///
    /// The memory keeps its `id`. A path starts with `/` and has 1 to 20 segments. A
    /// segment can't be empty and can't be `.` or `..`. A path can't contain control
    /// characters, format characters, or the line and paragraph separators U+2028 and
    /// U+2029. It must be in Unicode Normalization Form C and at most 1,024 bytes long.
    /// Paths are case-sensitive.
    public var path: String??
    /// The condition that the memory must meet for the update to apply.
    ///
    /// Omit it to update unconditionally.
    ///
    /// If the condition fails, the request fails with HTTP status 409.
    public var precondition: BetaManagedAgentsPreconditionParam?
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
    public var workspaceID: String?

    public init(memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, content: String?? = nil, path: String?? = nil, precondition: BetaManagedAgentsPreconditionParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.memoryStoreID = memoryStoreID
        self.view = view
        self.content = content
        self.path = path
        self.precondition = precondition
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreID = "memory_store_id"
        case view
        case content
        case path
        case precondition
        case betas
        case workspaceID = "workspace_id"
    }
}
