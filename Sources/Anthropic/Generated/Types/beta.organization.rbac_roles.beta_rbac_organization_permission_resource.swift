// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_organization_permission_resource` (beta_rbac_organization_permission_resource.py).

import Foundation

public struct BetaRBACOrganizationPermissionResource: Codable, Hashable, Sendable {
    /// UUID of the organization the permission applies to.
    public var organizationId: String
    /// Kind of resource the permission applies to.
    public var type: String

    public init(organizationId: String, type: String = "organization") {
        self.organizationId = organizationId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case organizationId = "organization_id"
        case type
    }
}
