// Transformed from `anthropic.types.organization.workspace_member` (workspace_member.py).

import Foundation

public struct WorkspaceMember: Codable, Hashable, Sendable {
    /// Object type.
    ///
    /// For Workspace Members, this is always `"workspace_member"`.
    public var type: String
    /// ID of the User.
    public var userId: String
    /// ID of the Workspace.
    public var workspaceId: String
    /// Role of the Workspace Member.
    public var workspaceRole: WorkspaceRole

    public init(type: String = "workspace_member", userId: String, workspaceId: String, workspaceRole: WorkspaceRole) {
        self.type = type
        self.userId = userId
        self.workspaceId = workspaceId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
        case workspaceId = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
