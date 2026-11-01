// Transformed from `anthropic.types.beta.memory_stores.memory_retrieve_params` (memory_retrieve_params.py).

import Foundation

public struct MemoryRetrieveParams: Codable, Hashable, Sendable {
    /// The ID of the memory store that holds the memory (`memstore_...`).
    public var memoryStoreID: String
    /// Whether a `memory` or `memory_version` in the response includes its `content`.
    ///
    /// Defaults to `full` on retrieve operations and to `basic` on list, create, and
    /// update operations.
    ///
    /// With `full`, list operations return at most 20 items per page.
    public var view: BetaManagedAgentsMemoryView?
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

    public init(memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.memoryStoreID = memoryStoreID
        self.view = view
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreID = "memory_store_id"
        case view
        case betas
        case workspaceID = "workspace_id"
    }
}
