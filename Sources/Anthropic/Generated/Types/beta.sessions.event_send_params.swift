// Transformed from `anthropic.types.beta.sessions.event_send_params` (event_send_params.py).

import Foundation

public struct EventSendParams: Codable, Hashable, Sendable {
    /// Events to send to the `session`.
    public var events: [BetaManagedAgentsEventParams]
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

    public init(events: [BetaManagedAgentsEventParams], betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.events = events
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case events
        case betas
        case workspaceId = "workspace_id"
    }
}
