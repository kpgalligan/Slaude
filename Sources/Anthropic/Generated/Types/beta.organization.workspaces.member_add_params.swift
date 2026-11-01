// Transformed from `anthropic.types.beta.organization.workspaces.member_add_params` (member_add_params.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberAddParams: Codable, Hashable, Sendable {
    /// ID of the User.
    public var userId: String
    /// Role of the new Workspace Member. Cannot be `workspace_billing`.
    public var workspaceRole: BetaNoBillingWorkspaceRole

    public init(userId: String, workspaceRole: BetaNoBillingWorkspaceRole) {
        self.userId = userId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case workspaceRole = "workspace_role"
    }
}
