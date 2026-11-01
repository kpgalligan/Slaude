// Transformed from `anthropic.types.deleted_user_profile` (deleted_user_profile.py).

import Foundation

public struct DeletedUserProfile: Codable, Hashable, Sendable {
    /// Identifier of the deleted user profile, prefixed `uprof_`.
    public var id: String
    /// Object type. Always `user_profile_deleted`.
    public var type: String

    public init(id: String, type: String = "user_profile_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
