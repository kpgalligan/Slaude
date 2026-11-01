// Transformed from `anthropic.types.beta.organization.beta_analytics_user_actor` (beta_analytics_user_actor.py).

import Foundation

public struct BetaAnalyticsUserActor: Codable, Hashable, Sendable {
    /// True when the account has been deleted, or when the user is no longer a member
    /// of the organization or its associated organizations (for example, their
    /// membership was removed or they were deprovisioned via your identity provider).
    /// `email_address` stays populated for removed users and is null when the account
    /// has been deleted. `name` follows the rules described on that field. The
    /// `user_id` is still populated for reconciliation.
    public var deleted: Bool
    /// The user's email address, including for users who are no longer members of the
    /// organization or its associated organizations. Null when the account has been
    /// deleted (check `deleted`) and for system-minted service accounts, which have no
    /// person's mailbox behind them (check `name`).
    public var emailAddress: String?
    /// The user's full name.
    ///
    /// Null when the user has not set a name. Returns `"Deleted User"` when the account
    /// itself has been deleted, or when the user is no longer a member of the
    /// organization or its associated organizations and the organization has chosen to
    /// hide the names of removed users. Otherwise, the name stays populated for removed
    /// users. Rows for system-minted service accounts render the service name (for
    /// example, `"Claude Security"` for usage by Anthropic's security-patching service)
    /// or null.
    public var name: String?
    /// Actor type. Always `"user_actor"`.
    public var type: String
    /// Tagged user ID.
    public var userID: String

    public init(deleted: Bool, emailAddress: String? = nil, name: String? = nil, type: String = "user_actor", userID: String) {
        self.deleted = deleted
        self.emailAddress = emailAddress
        self.name = name
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case deleted
        case emailAddress = "email_address"
        case name
        case type
        case userID = "user_id"
    }
}
