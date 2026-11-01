// Transformed from `anthropic.types.organization.service_accounts.workspace_add_params` (workspace_add_params.py).

import Foundation

public struct WorkspaceAddParams: Codable, Hashable, Sendable {
    /// Tagged workspace ID to add the service account to.
    public var workspaceId: String
    /// Role to assign to the service account in this workspace.
    public var workspaceRole: NoBillingWorkspaceRole

    public init(workspaceId: String, workspaceRole: NoBillingWorkspaceRole) {
        self.workspaceId = workspaceId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
