// Transformed from `anthropic.types.beta.organization.rbac_group_create_params` (rbac_group_create_params.py).

import Foundation

public struct RBACGroupCreateParams: Codable, Hashable, Sendable {
    /// Name of the RBAC Group. Not uniqueness-enforced.
    public var name: String

    public init(name: String) {
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case name
    }
}
