// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_role_permission` (beta_rbac_role_permission.py).

import Foundation

public struct BetaRBACRolePermission: Codable, Hashable, Sendable {
    /// Action the permission grants on the resource.
    ///
    /// The vocabulary follows the resource: an `organization` grant carries a
    /// product-feature entitlement (for example `chat`), an admin-panel permission
    /// entitlement (`permission_*`), or a blanket capability-access mode —
    /// `capability_access_all` grants every product-feature entitlement, and
    /// `capability_access_all_ga` grants the generally-available subset as it stands at
    /// permission-check time; neither mode grants model-access entitlements. A consumer
    /// enumerating a role's per-feature grants should treat a blanket row as granting
    /// every product-feature entitlement it covers, or it will under-report the role's
    /// effective access. A `connector_tool` grant carries a tool-access action (`use`
    /// or `always_allow`); a `connector_scope` grant carries the scope action `grant`
    /// (the role may receive the named OAuth scope when tokens are minted for the
    /// connector); `connector` and `all_connectors` grants carry a tool-access action,
    /// the scope action, or an authentication-method action (`interactive` or
    /// `managed`).
    public var action: String
    /// What the permission applies to.
    ///
    /// A tagged union: `type` names the kind of resource and determines which
    /// identifier fields are present.
    public var resource: BetaRBACRolePermission.Resource
    /// Object type.
    ///
    /// For RBAC Role Permissions, this is always `"rbac_role_permission"`.
    public var type: String

    public init(action: String, resource: BetaRBACRolePermission.Resource, type: String = "rbac_role_permission") {
        self.action = action
        self.resource = resource
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case action
        case resource
        case type
    }
}

extension BetaRBACRolePermission {

    public indirect enum Resource: Codable, Hashable, Sendable {
        case organization(BetaRBACOrganizationPermissionResource)
        case connectorTool(BetaRBACConnectorToolPermissionResource)
        case connectorScope(BetaRBACConnectorScopePermissionResource)
        case connector(BetaRBACConnectorPermissionResource)
        case allConnectors(BetaRBACAllConnectorsPermissionResource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "organization": self = .organization(try BetaRBACOrganizationPermissionResource(from: decoder))
            case "connector_tool": self = .connectorTool(try BetaRBACConnectorToolPermissionResource(from: decoder))
            case "connector_scope": self = .connectorScope(try BetaRBACConnectorScopePermissionResource(from: decoder))
            case "connector": self = .connector(try BetaRBACConnectorPermissionResource(from: decoder))
            case "all_connectors": self = .allConnectors(try BetaRBACAllConnectorsPermissionResource(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .organization(let v): try v.encode(to: encoder)
            case .connectorTool(let v): try v.encode(to: encoder)
            case .connectorScope(let v): try v.encode(to: encoder)
            case .connector(let v): try v.encode(to: encoder)
            case .allConnectors(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
