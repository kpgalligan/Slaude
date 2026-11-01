// Transformed from `anthropic.types.beta.organization.beta_spend_limit_rbac_group_scope` (beta_spend_limit_rbac_group_scope.py).

import Foundation

public struct BetaSpendLimitRBACGroupScope: Codable, Hashable, Sendable {
    public var rbacGroupId: String
    public var type: String

    public init(rbacGroupId: String, type: String = "rbac_group") {
        self.rbacGroupId = rbacGroupId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case rbacGroupId = "rbac_group_id"
        case type
    }
}
