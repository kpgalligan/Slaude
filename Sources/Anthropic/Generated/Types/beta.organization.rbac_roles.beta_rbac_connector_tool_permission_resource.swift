// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_connector_tool_permission_resource` (beta_rbac_connector_tool_permission_resource.py).

import Foundation

public struct BetaRBACConnectorToolPermissionResource: Codable, Hashable, Sendable {
    /// ID of the connector the permission applies to.
    public var connectorId: String
    /// Published name of the connector tool the permission applies to.
    ///
    /// When the published name contains characters outside `[a-zA-Z0-9_-]` (or collides
    /// with a reserved form), it is server-encoded into a stable `{prefix}_{32-hex}`
    /// form — a shortened readable prefix of the name plus a hash — from which the
    /// published name is not recoverable.
    public var toolName: String
    /// Kind of resource the permission applies to.
    public var type: String

    public init(connectorId: String, toolName: String, type: String = "connector_tool") {
        self.connectorId = connectorId
        self.toolName = toolName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case connectorId = "connector_id"
        case toolName = "tool_name"
        case type
    }
}
