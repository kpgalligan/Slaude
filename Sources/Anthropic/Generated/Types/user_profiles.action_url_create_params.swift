// Transformed from `anthropic.types.user_profiles.action_url_create_params` (action_url_create_params.py).

import Foundation

public struct ActionURLCreateParams: Codable, Hashable, Sendable {
    /// The action that the person who opens the URL takes.
    public var action: UserProfileEnrollEndUserActionParam
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(action: UserProfileEnrollEndUserActionParam, workspaceID: String? = nil) {
        self.action = action
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case action
        case workspaceID = "workspace_id"
    }
}
