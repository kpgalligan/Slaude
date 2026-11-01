// Transformed from `anthropic.types.beta.environments.work_update_params` (work_update_params.py).

import Foundation

public struct WorkUpdateParams: Codable, Hashable, Sendable {
    public var environmentID: String
    /// Metadata patch.
    ///
    /// Set a key to a string to upsert it, or to null to delete it. Omit the field to
    /// preserve existing metadata.
    public var metadata: [String: String?]
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(environmentID: String, metadata: [String: String?], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.environmentID = environmentID
        self.metadata = metadata
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case metadata
        case betas
        case workspaceID = "workspace_id"
    }
}
