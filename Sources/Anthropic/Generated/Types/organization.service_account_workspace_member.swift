// Transformed from `anthropic.types.organization.service_account_workspace_member` (service_account_workspace_member.py).

import Foundation

public struct ServiceAccountWorkspaceMember: Codable, Hashable, Sendable {
    /// Tagged ID (`user_...`/`svac_...`) of the actor who created this membership.
    public var createdByActorId: String?
    /// True when this is the implicit default-workspace membership every service
    /// account has when no explicit membership exists. Implicit memberships have role
    /// `workspace_user` and cannot be removed.
    public var implicit: Bool?
    /// Tagged service account ID (`svac_...`).
    public var serviceAccountId: String
    public var type: String
    /// Tagged workspace ID (`wrkspc_...`).
    public var workspaceId: String
    /// Role of the service account in this workspace.
    ///
    /// Service accounts cannot hold the `workspace_billing` role.
    public var workspaceRole: WorkspaceRole

    public init(createdByActorId: String? = nil, implicit: Bool? = nil, serviceAccountId: String, type: String = "service_account_workspace_member", workspaceId: String, workspaceRole: WorkspaceRole) {
        self.createdByActorId = createdByActorId
        self.implicit = implicit
        self.serviceAccountId = serviceAccountId
        self.type = type
        self.workspaceId = workspaceId
        self.workspaceRole = workspaceRole
    }

    enum CodingKeys: String, CodingKey {
        case createdByActorId = "created_by_actor_id"
        case implicit
        case serviceAccountId = "service_account_id"
        case type
        case workspaceId = "workspace_id"
        case workspaceRole = "workspace_role"
    }
}
