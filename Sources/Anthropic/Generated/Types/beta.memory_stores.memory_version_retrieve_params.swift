// Transformed from `anthropic.types.beta.memory_stores.memory_version_retrieve_params` (memory_version_retrieve_params.py).

import Foundation

public struct MemoryVersionRetrieveParams: Codable, Hashable, Sendable {
    /// The ID of the memory store that holds the version (`memstore_...`).
    public var memoryStoreId: String
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
    public var workspaceId: String?

    public init(memoryStoreId: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.memoryStoreId = memoryStoreId
        self.view = view
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case view
        case betas
        case workspaceId = "workspace_id"
    }
}
