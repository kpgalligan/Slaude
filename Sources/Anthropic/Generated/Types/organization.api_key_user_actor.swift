// Transformed from `anthropic.types.organization.api_key_user_actor` (api_key_user_actor.py).

import Foundation

public struct APIKeyUserActor: Codable, Hashable, Sendable {
    /// Principal type. Always `"user_actor"` for a User.
    public var type: String
    /// ID of the User the API key acts as.
    public var userId: String

    public init(type: String = "user_actor", userId: String) {
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
    }
}
