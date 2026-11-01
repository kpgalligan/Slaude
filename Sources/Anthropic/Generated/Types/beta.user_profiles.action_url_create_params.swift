// Transformed from `anthropic.types.beta.user_profiles.action_url_create_params` (action_url_create_params.py).

import Foundation

public struct BetaUserProfilesActionURLCreateParams: Codable, Hashable, Sendable {
    /// The action that the person who opens the URL takes.
    public var action: BetaUserProfileEnrollEndUserActionParam
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(action: BetaUserProfileEnrollEndUserActionParam, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.action = action
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case action
        case betas
        case workspaceId = "workspace_id"
    }
}
