// Transformed from `anthropic.types.organization.workspaces.service_account_update_params` (service_account_update_params.py).

import Foundation

public struct OrganizationWorkspacesServiceAccountUpdateParams: Codable, Hashable, Sendable {
    /// ID of the workspace.
    public var workspaceId: String
    /// New role for the service account in this workspace.
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
