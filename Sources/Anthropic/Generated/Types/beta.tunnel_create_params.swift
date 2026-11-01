// Transformed from `anthropic.types.beta.tunnel_create_params` (tunnel_create_params.py).

import Foundation

public struct TunnelCreateParams: Codable, Hashable, Sendable {
    /// Optional human-readable name for the tunnel (1-255 characters).
    public var displayName: String??
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

    public init(displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.displayName = displayName
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case betas
        case workspaceID = "workspace_id"
    }
}
