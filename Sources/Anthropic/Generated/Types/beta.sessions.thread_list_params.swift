// Transformed from `anthropic.types.beta.sessions.thread_list_params` (thread_list_params.py).

import Foundation

public struct ThreadListParams: Codable, Hashable, Sendable {
    /// Maximum results per page. Defaults to 1000.
    public var limit: Int?
    /// Opaque pagination cursor from a previous response's `next_page`. Forward-only.
    public var page: String?
    /// Return only threads that have one of these statuses.
    ///
    /// Repeat the parameter to give more than one status. Leave it out to return
    /// threads of every status.
    public var statuses: [BetaManagedAgentsSessionThreadStatus]?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(limit: Int? = nil, page: String? = nil, statuses: [BetaManagedAgentsSessionThreadStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.limit = limit
        self.page = page
        self.statuses = statuses
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case statuses
        case betas
        case workspaceId = "workspace_id"
    }
}
