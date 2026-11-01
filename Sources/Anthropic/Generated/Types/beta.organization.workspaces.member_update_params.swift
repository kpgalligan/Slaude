// Transformed from `anthropic.types.beta.organization.workspaces.member_update_params` (member_update_params.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberUpdateParams: Codable, Hashable, Sendable {
    /// ID of the Workspace.
    public var workspaceID: String
    /// New workspace role for the User.
    public var workspaceRole: BetaWorkspaceRole

    public init(workspaceID: String, workspaceRole: BetaWorkspaceRole) {
        self.workspaceID = workspaceID
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
