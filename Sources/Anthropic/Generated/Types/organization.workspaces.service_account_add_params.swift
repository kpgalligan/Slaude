// Transformed from `anthropic.types.organization.workspaces.service_account_add_params` (service_account_add_params.py).

import Foundation

public struct ServiceAccountAddParams: Codable, Hashable, Sendable {
    /// Tagged service account ID to add.
    public var serviceAccountID: String
    /// Role to assign to the service account in this workspace.
    public var workspaceRole: NoBillingWorkspaceRole

    public init(serviceAccountID: String, workspaceRole: NoBillingWorkspaceRole) {
        self.serviceAccountID = serviceAccountID
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountID = "service_account_id"
        case workspaceRole = "workspace_role"
    }
}
