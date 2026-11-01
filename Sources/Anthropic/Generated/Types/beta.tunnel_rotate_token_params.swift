// Transformed from `anthropic.types.beta.tunnel_rotate_token_params` (tunnel_rotate_token_params.py).

import Foundation

public struct TunnelRotateTokenParams: Codable, Hashable, Sendable {
    /// Optional free-text reason for the rotation, recorded for audit.
    public var reason: String??
    /// This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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

    public init(reason: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.reason = reason
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case reason
        case betas
        case workspaceID = "workspace_id"
    }
}
