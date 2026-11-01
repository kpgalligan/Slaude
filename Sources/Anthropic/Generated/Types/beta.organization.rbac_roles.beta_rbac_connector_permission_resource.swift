// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_connector_permission_resource` (beta_rbac_connector_permission_resource.py).

import Foundation

public struct BetaRBACConnectorPermissionResource: Codable, Hashable, Sendable {
    /// ID of the connector the permission applies to.
    public var connectorId: String
    /// Kind of resource the permission applies to.
    public var type: String

    public init(connectorId: String, type: String = "connector") {
        self.connectorId = connectorId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case connectorId = "connector_id"
        case type
    }
}
