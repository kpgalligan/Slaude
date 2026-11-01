// Transformed from `anthropic.types.beta.organization.service_accounts.workspace_remove_response` (workspace_remove_response.py).

import Foundation

public struct BetaOrganizationServiceAccountsWorkspaceRemoveResponse: Codable, Hashable, Sendable {
    /// Tagged service account ID (`svac_...`) named in the delete request.
    ///
    /// Removal is idempotent; see the endpoint description for the implicit-membership
    /// no-op.
    public var serviceAccountId: String
    public var type: String
    /// Tagged workspace ID (`wrkspc_...`) named in the delete request.
    public var workspaceId: String

    public init(serviceAccountId: String, type: String = "service_account_workspace_member_deleted", workspaceId: String) {
        self.serviceAccountId = serviceAccountId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountId = "service_account_id"
        case type
        case workspaceId = "workspace_id"
    }
}
