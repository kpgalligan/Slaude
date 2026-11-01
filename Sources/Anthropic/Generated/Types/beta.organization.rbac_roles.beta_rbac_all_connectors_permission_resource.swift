// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_all_connectors_permission_resource` (beta_rbac_all_connectors_permission_resource.py).

import Foundation

public struct BetaRBACAllConnectorsPermissionResource: Codable, Hashable, Sendable {
    /// Kind of resource the permission applies to.
    public var type: String

    public init(type: String = "all_connectors") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
