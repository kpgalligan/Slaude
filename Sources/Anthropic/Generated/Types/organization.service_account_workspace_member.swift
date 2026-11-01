// Transformed from `anthropic.types.organization.service_account_workspace_member` (service_account_workspace_member.py).

import Foundation

public struct ServiceAccountWorkspaceMember: Codable, Hashable, Sendable {
    /// Tagged ID (`user_...`/`svac_...`) of the actor who created this membership.
    public var createdByActorID: String?
    /// True when this is the implicit default-workspace membership every service
    /// account has when no explicit membership exists. Implicit memberships have role
    /// `workspace_user` and cannot be removed.
    public var implicit: Bool?
    /// Tagged service account ID (`svac_...`).
    public var serviceAccountID: String
    public var type: String
    /// Tagged workspace ID (`wrkspc_...`).
    public var workspaceID: String
    /// Role of the service account in this workspace.
    ///
    /// Service accounts cannot hold the `workspace_billing` role.
    public var workspaceRole: WorkspaceRole

    public init(createdByActorID: String? = nil, implicit: Bool? = nil, serviceAccountID: String, type: String = "service_account_workspace_member", workspaceID: String, workspaceRole: WorkspaceRole) {
        self.createdByActorID = createdByActorID
        self.implicit = implicit
        self.serviceAccountID = serviceAccountID
        self.type = type
        self.workspaceID = workspaceID
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case createdByActorID = "created_by_actor_id"
        case implicit
        case serviceAccountID = "service_account_id"
        case type
        case workspaceID = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
