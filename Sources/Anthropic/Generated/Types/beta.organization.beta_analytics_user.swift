// Transformed from `anthropic.types.beta.organization.beta_analytics_user` (beta_analytics_user.py).

import Foundation

/// A user in the organization, identified by tagged id and email address.
public struct BetaAnalyticsUser: Codable, Hashable, Sendable {
    /// Tagged user identifier (e.g. `user_...`)
    public var id: String
    /// Email address of the user
    public var emailAddress: String
    /// Object type. Always `user`.
    public var type: String

    public init(id: String, emailAddress: String, type: String = "user") {
        self.id = id
        self.emailAddress = emailAddress
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case emailAddress = "email_address"
        case type
    }
}
