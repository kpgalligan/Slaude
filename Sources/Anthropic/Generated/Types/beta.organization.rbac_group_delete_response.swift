// Transformed from `anthropic.types.beta.organization.rbac_group_delete_response` (rbac_group_delete_response.py).

import Foundation

public struct RBACGroupDeleteResponse: Codable, Hashable, Sendable {
    /// ID of the RBAC Group.
    public var id: String
    /// Deleted object type.
    ///
    /// For RBAC Groups, this is always `"rbac_group_deleted"`.
    public var type: String

    public init(id: String, type: String = "rbac_group_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
