// Transformed from `anthropic.types.beta.memory_stores.memory_delete_params` (memory_delete_params.py).

import Foundation

public struct MemoryDeleteParams: Codable, Hashable, Sendable {
    /// The ID of the memory store that holds the memory (`memstore_...`).
    public var memoryStoreId: String
    /// Delete the memory only if its current `content_sha256` equals this value, given
    /// as 64 lowercase hexadecimal characters. Omit it to delete unconditionally.
    ///
    /// If the hashes differ, the request fails with HTTP status 409 and nothing is
    /// deleted.
    public var expectedContentSha256: String?
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

    public init(memoryStoreId: String, expectedContentSha256: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.memoryStoreId = memoryStoreId
        self.expectedContentSha256 = expectedContentSha256
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case expectedContentSha256 = "expected_content_sha256"
        case betas
        case workspaceId = "workspace_id"
    }
}
