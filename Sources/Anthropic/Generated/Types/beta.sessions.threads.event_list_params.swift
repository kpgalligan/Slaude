// Transformed from `anthropic.types.beta.sessions.threads.event_list_params` (event_list_params.py).

import Foundation

public struct BetaSessionsThreadsEventListParams: Codable, Hashable, Sendable {
    public var sessionID: String
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
    public var workspaceID: String?

    public init(sessionID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.sessionID = sessionID
        self.limit = limit
        self.page = page
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case limit
        case page
        case betas
        case workspaceID = "workspace_id"
    }
}
