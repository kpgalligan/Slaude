// Transformed from `anthropic.types.beta.agent_retrieve_params` (agent_retrieve_params.py).

import Foundation

public struct AgentRetrieveParams: Codable, Hashable, Sendable {
    /// Agent version.
    ///
    /// Omit for the most recent version. Must be at least 1 if specified.
    public var version: Int?
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

    public init(version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.version = version
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case version
        case betas
        case workspaceID = "workspace_id"
    }
}
