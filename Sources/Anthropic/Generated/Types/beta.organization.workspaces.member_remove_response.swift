// Transformed from `anthropic.types.beta.organization.workspaces.member_remove_response` (member_remove_response.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberRemoveResponse: Codable, Hashable, Sendable {
    /// Deleted object type.
    ///
    /// For Workspace Members, this is always `"workspace_member_deleted"`.
    public var type: String
    /// ID of the User.
    public var userID: String
    /// ID of the Workspace.
    public var workspaceID: String

    public init(type: String = "workspace_member_deleted", userID: String, workspaceID: String) {
        self.type = type
        self.userID = userID
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
        case workspaceID = "workspace_id"
    }
}
