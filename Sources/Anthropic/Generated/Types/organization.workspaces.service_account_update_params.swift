// Transformed from `anthropic.types.organization.workspaces.service_account_update_params` (service_account_update_params.py).

import Foundation

public struct OrganizationWorkspacesServiceAccountUpdateParams: Codable, Hashable, Sendable {
    /// ID of the workspace.
    public var workspaceID: String
    /// New role for the service account in this workspace.
    public var workspaceRole: NoBillingWorkspaceRole

    public init(workspaceID: String, workspaceRole: NoBillingWorkspaceRole) {
        self.workspaceID = workspaceID
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
