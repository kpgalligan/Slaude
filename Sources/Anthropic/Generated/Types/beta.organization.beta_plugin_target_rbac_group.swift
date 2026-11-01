// Transformed from `anthropic.types.beta.organization.beta_plugin_target_rbac_group` (beta_plugin_target_rbac_group.py).

import Foundation

public struct BetaPluginTargetRBACGroup: Codable, Hashable, Sendable {
    /// The RBAC Group's ID.
    public var rbacGroupID: String
    /// An RBAC Group.
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
