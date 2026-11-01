// Transformed from `anthropic.types.beta.organization.beta_plugin_target_rbac_group` (beta_plugin_target_rbac_group.py).

import Foundation

public struct BetaPluginTargetRBACGroup: Codable, Hashable, Sendable {
    /// The RBAC Group's ID.
    public var rbacGroupId: String
    /// An RBAC Group.
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
