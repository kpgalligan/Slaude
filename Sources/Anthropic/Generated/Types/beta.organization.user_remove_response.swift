// Transformed from `anthropic.types.beta.organization.user_remove_response` (user_remove_response.py).

import Foundation

public struct BetaOrganizationUserRemoveResponse: Codable, Hashable, Sendable {
    /// ID of the User.
    public var id: String
    /// Deleted object type.
    ///
    /// For Users, this is always `"user_deleted"`.
    public var type: String

    public init(id: String, type: String = "user_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
