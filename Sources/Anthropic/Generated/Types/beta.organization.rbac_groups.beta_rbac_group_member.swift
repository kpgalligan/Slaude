// Transformed from `anthropic.types.beta.organization.rbac_groups.beta_rbac_group_member` (beta_rbac_group_member.py).

import Foundation

public struct BetaRBACGroupMember: Codable, Hashable, Sendable {
    /// RFC 3339 timestamp of when the User was added to the RBAC Group.
    public var createdAt: Date
    /// Email of the User.
    public var email: String
    /// ID of the RBAC Group.
    public var rbacGroupId: String
    /// Object type.
    ///
    /// For RBAC Group Members, this is always `"rbac_group_member"`.
    public var type: String
    /// ID of the User.
    public var userId: String

    public init(createdAt: Date, email: String, rbacGroupId: String, type: String = "rbac_group_member", userId: String) {
        self.createdAt = createdAt
        self.email = email
        self.rbacGroupId = rbacGroupId
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case email
        case rbacGroupId = "rbac_group_id"
        case type
        case userId = "user_id"
    }
}
