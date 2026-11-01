// Transformed from `anthropic.types.beta.organization.beta_plugin_user_actor` (beta_plugin_user_actor.py).

import Foundation

public struct BetaPluginUserActor: Codable, Hashable, Sendable {
    /// The member's email address; may be null, for example when they are no longer a
    /// member of the organization.
    public var emailAddress: String?
    /// A member of the organization.
    public var type: String
    /// The member's User ID.
    public var userID: String

    public init(emailAddress: String? = nil, type: String = "user_actor", userID: String) {
        self.emailAddress = emailAddress
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case type
        case userID = "user_id"
    }
}
