// Transformed from `anthropic.types.organization.service_accounts.workspace_remove_response` (workspace_remove_response.py).

import Foundation

public struct WorkspaceRemoveResponse: Codable, Hashable, Sendable {
    /// Tagged service account ID (`svac_...`) named in the delete request.
    ///
    /// Removal is idempotent; see the endpoint description for the implicit-membership
    /// no-op.
    public var serviceAccountID: String
    public var type: String
    /// Tagged workspace ID (`wrkspc_...`) named in the delete request.
    public var workspaceID: String

    public init(serviceAccountID: String, type: String = "service_account_workspace_member_deleted", workspaceID: String) {
        self.serviceAccountID = serviceAccountID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountID = "service_account_id"
        case type
        case workspaceID = "workspace_id"
    }
}
