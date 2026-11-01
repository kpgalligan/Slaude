// Transformed from `anthropic.types.beta.vault_create_params` (vault_create_params.py).

import Foundation

public struct VaultCreateParams: Codable, Hashable, Sendable {
    /// Human-readable name for the vault. 1-255 characters.
    public var displayName: String
    /// Arbitrary key-value metadata to attach to the vault.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]?
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

    public init(displayName: String, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.displayName = displayName
        self.metadata = metadata
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case metadata
        case betas
        case workspaceId = "workspace_id"
    }
}
