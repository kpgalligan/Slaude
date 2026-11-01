// Transformed from `anthropic.types.beta.organization.rbac_groups.beta_rbac_group_member` (beta_rbac_group_member.py).

import Foundation

public struct BetaRBACGroupMember: Codable, Hashable, Sendable {
    /// RFC 3339 timestamp of when the User was added to the RBAC Group.
    public var createdAt: Date
    /// Email of the User.
    public var email: String
    /// ID of the RBAC Group.
    public var rbacGroupID: String
    /// Object type.
    ///
    /// For RBAC Group Members, this is always `"rbac_group_member"`.
    public var type: String
    /// ID of the User.
    public var userID: String

    public init(createdAt: Date, email: String, rbacGroupID: String, type: String = "rbac_group_member", userID: String) {
        self.createdAt = createdAt
        self.email = email
        self.rbacGroupID = rbacGroupID
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case email
        case rbacGroupID = "rbac_group_id"
        case type
        case userID = "user_id"
    }
}
