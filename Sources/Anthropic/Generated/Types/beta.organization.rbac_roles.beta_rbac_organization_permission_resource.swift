// Transformed from `anthropic.types.beta.organization.rbac_roles.beta_rbac_organization_permission_resource` (beta_rbac_organization_permission_resource.py).

import Foundation

public struct BetaRBACOrganizationPermissionResource: Codable, Hashable, Sendable {
    /// UUID of the organization the permission applies to.
    public var organizationID: String
    /// Kind of resource the permission applies to.
    public var type: String

    public init(organizationID: String, type: String = "organization") {
        self.organizationID = organizationID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case organizationID = "organization_id"
        case type
    }
}
