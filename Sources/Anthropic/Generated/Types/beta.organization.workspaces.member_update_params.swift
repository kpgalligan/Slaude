// Transformed from `anthropic.types.beta.organization.workspaces.member_update_params` (member_update_params.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberUpdateParams: Codable, Hashable, Sendable {
    /// ID of the Workspace.
    public var workspaceId: String
    /// New workspace role for the User.
    public var workspaceRole: BetaWorkspaceRole

    public init(workspaceId: String, workspaceRole: BetaWorkspaceRole) {
        self.workspaceId = workspaceId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
