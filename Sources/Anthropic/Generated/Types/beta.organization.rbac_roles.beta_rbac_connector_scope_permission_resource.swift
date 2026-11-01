// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_connector_scope_permission_resource` (beta_rbac_connector_scope_permission_resource.py).

import Foundation

public struct BetaRBACConnectorScopePermissionResource: Codable, Hashable, Sendable {
    /// ID of the connector the permission applies to.
    public var connectorId: String
    /// OAuth scope the permission names — the role may receive this scope when tokens
    /// are minted for the connector.
    ///
    /// Subject to the same encoding rule as `tool_name`: a scope containing characters
    /// outside `[a-zA-Z0-9_-]` (or colliding with a reserved form) appears
    /// server-encoded in a stable `{prefix}_{32-hex}` form. OAuth scopes routinely
    /// contain `:` and `/`, so most appear encoded.
    public var scope: String
    /// Kind of resource the permission applies to.
    public var type: String

    public init(connectorId: String, scope: String, type: String = "connector_scope") {
        self.connectorId = connectorId
        self.scope = scope
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case connectorId = "connector_id"
        case scope
        case type
    }
}
