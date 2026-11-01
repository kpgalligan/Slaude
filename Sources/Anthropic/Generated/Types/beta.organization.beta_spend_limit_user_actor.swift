// Transformed from `anthropic.types.beta.organization.beta_spend_limit_user_actor` (beta_spend_limit_user_actor.py).

import Foundation

/// A user within the organization.
///
/// `name` and `email_address` are
/// null when the underlying account is unavailable or has been deleted;
/// `deleted` is true only for deleted accounts.
public struct BetaSpendLimitUserActor: Codable, Hashable, Sendable {
    /// True only when the underlying account has been deleted.
    public var deleted: Bool
    /// The user's email address.
    ///
    /// Null when the account is unavailable or has been deleted.
    public var emailAddress: String?
    /// The user's current display name.
    ///
    /// Null when the account is unavailable, has been deleted, or has no name set.
    public var name: String?
    /// Actor type. Always `user_actor`.
    public var type: String
    /// Tagged ID of the user.
    public var userId: String

    public init(deleted: Bool, emailAddress: String? = nil, name: String? = nil, type: String = "user_actor", userId: String) {
        self.deleted = deleted
        self.emailAddress = emailAddress
        self.name = name
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case deleted
        case emailAddress = "email_address"
        case name
        case type
        case userId = "user_id"
    }
}
