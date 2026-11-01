// Transformed from `anthropic.types.beta.organization.workspaces.member_remove_response` (member_remove_response.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberRemoveResponse: Codable, Hashable, Sendable {
    /// Deleted object type.
    ///
    /// For Workspace Members, this is always `"workspace_member_deleted"`.
    public var type: String
    /// ID of the User.
    public var userId: String
    /// ID of the Workspace.
    public var workspaceId: String

    public init(type: String = "workspace_member_deleted", userId: String, workspaceId: String) {
        self.type = type
        self.userId = userId
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
        case workspaceId = "workspace_id"
    }
}
