// Transformed from `anthropic.types.beta.organization.beta_spend_limit_rbac_group_scope` (beta_spend_limit_rbac_group_scope.py).

import Foundation

public struct BetaSpendLimitRBACGroupScope: Codable, Hashable, Sendable {
    public var rbacGroupID: String
    public var type: String

    public init(rbacGroupID: String, type: String = "rbac_group") {
        self.rbacGroupID = rbacGroupID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case rbacGroupID = "rbac_group_id"
        case type
    }
}
