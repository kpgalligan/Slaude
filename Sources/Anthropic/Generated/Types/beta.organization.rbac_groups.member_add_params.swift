// Transformed from `anthropic.types.beta.organization.rbac_groups.member_add_params` (member_add_params.py).

import Foundation

public struct BetaOrganizationRbacGroupsMemberAddParams: Codable, Hashable, Sendable {
    /// ID of the User.
    public var userID: String

    public init(userID: String) {
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
