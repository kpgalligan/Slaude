// Transformed from `anthropic.types.organization.api_key_user_actor` (api_key_user_actor.py).

import Foundation

public struct APIKeyUserActor: Codable, Hashable, Sendable {
    /// Principal type. Always `"user_actor"` for a User.
    public var type: String
    /// ID of the User the API key acts as.
    public var userID: String

    public init(type: String = "user_actor", userID: String) {
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
    }
}
