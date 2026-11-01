// Transformed from `anthropic.types.beta.organization.rbac_group_update_params` (rbac_group_update_params.py).

import Foundation

public struct RBACGroupUpdateParams: Codable, Hashable, Sendable {
    /// Name of the RBAC Group. Not uniqueness-enforced.
    public var name: String??

    public init(name: String?? = nil) {
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case name
    }
}
