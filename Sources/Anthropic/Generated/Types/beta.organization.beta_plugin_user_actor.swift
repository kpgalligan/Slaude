// Transformed from `anthropic.types.beta.organization.beta_plugin_user_actor` (beta_plugin_user_actor.py).

import Foundation

public struct BetaPluginUserActor: Codable, Hashable, Sendable {
    /// The member's email address; may be null, for example when they are no longer a
    /// member of the organization.
    public var emailAddress: String?
    /// A member of the organization.
    public var type: String
    /// The member's User ID.
    public var userId: String

    public init(emailAddress: String? = nil, type: String = "user_actor", userId: String) {
        self.emailAddress = emailAddress
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case type
        case userId = "user_id"
    }
}
