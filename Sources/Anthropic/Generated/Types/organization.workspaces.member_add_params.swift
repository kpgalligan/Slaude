// Transformed from `anthropic.types.organization.workspaces.member_add_params` (member_add_params.py).

import Foundation

public struct MemberAddParams: Codable, Hashable, Sendable {
    /// ID of the User.
    public var userId: String
    /// Role of the new Workspace Member. Cannot be `workspace_billing`.
    public var workspaceRole: NoBillingWorkspaceRole

    public init(userId: String, workspaceRole: NoBillingWorkspaceRole) {
        self.userId = userId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case workspaceRole = "workspace_role"
    }
}
