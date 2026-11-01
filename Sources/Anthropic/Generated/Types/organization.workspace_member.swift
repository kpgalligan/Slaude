// Transformed from `anthropic.types.organization.workspace_member` (workspace_member.py).

import Foundation

public struct WorkspaceMember: Codable, Hashable, Sendable {
    /// Object type.
    ///
    /// For Workspace Members, this is always `"workspace_member"`.
    public var type: String
    /// ID of the User.
    public var userID: String
    /// ID of the Workspace.
    public var workspaceID: String
    /// Role of the Workspace Member.
    public var workspaceRole: WorkspaceRole

    public init(type: String = "workspace_member", userID: String, workspaceID: String, workspaceRole: WorkspaceRole) {
        self.type = type
        self.userID = userID
        self.workspaceID = workspaceID
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
        case workspaceID = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
