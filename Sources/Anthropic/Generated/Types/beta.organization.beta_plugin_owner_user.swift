// Transformed from `anthropic.types.beta.organization.beta_plugin_owner_user` (beta_plugin_owner_user.py).

import Foundation

public struct BetaPluginOwnerUser: Codable, Hashable, Sendable {
    /// The Plugin lives in one member's personal plugin marketplace.
    public var type: String
    /// The member's User ID.
    public var userID: String

    public init(type: String = "user", userID: String) {
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
    }
}
