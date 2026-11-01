// Transformed from `anthropic.types.beta.organization.rbac_groups.member_add_params` (member_add_params.py).

import Foundation

public struct BetaOrganizationRbacGroupsMemberAddParams: Codable, Hashable, Sendable {
    /// ID of the User.
    public var userId: String

    public init(userId: String) {
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
