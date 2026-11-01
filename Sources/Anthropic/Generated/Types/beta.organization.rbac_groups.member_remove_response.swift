// Transformed from `anthropic.types.beta.organization.rbac_groups.member_remove_response` (member_remove_response.py).

import Foundation

public struct BetaOrganizationRbacGroupsMemberRemoveResponse: Codable, Hashable, Sendable {
    /// ID of the RBAC Group.
    public var rbacGroupId: String
    /// Deleted object type.
    ///
    /// For RBAC Group Members, this is always `"rbac_group_member_deleted"`.
    public var type: String
    /// ID of the User.
    public var userId: String

    public init(rbacGroupId: String, type: String = "rbac_group_member_deleted", userId: String) {
        self.rbacGroupId = rbacGroupId
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case rbacGroupId = "rbac_group_id"
        case type
        case userId = "user_id"
    }
}
