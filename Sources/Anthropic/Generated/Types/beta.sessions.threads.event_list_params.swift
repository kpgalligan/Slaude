// Transformed from `anthropic.types.beta.sessions.threads.event_list_params` (event_list_params.py).

import Foundation

public struct BetaSessionsThreadsEventListParams: Codable, Hashable, Sendable {
    public var sessionId: String
    public var limit: Int?
    public var page: String?
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

    public init(sessionId: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.sessionId = sessionId
        self.limit = limit
        self.page = page
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case limit
        case page
        case betas
        case workspaceId = "workspace_id"
    }
}
