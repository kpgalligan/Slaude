// Transformed from `anthropic.types.beta.organization.rbac_groups.member_remove_response` (member_remove_response.py).

import Foundation

public struct BetaOrganizationRbacGroupsMemberRemoveResponse: Codable, Hashable, Sendable {
    /// ID of the RBAC Group.
    public var rbacGroupID: String
    /// Deleted object type.
    ///
    /// For RBAC Group Members, this is always `"rbac_group_member_deleted"`.
    public var type: String
    /// ID of the User.
    public var userID: String

    public init(rbacGroupID: String, type: String = "rbac_group_member_deleted", userID: String) {
        self.rbacGroupID = rbacGroupID
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case rbacGroupID = "rbac_group_id"
        case type
        case userID = "user_id"
    }
}
