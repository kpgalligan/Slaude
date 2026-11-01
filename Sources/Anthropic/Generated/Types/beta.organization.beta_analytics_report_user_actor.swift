// Transformed from `anthropic.types.beta.organization.beta_analytics_report_user_actor` (beta_analytics_report_user_actor.py).

import Foundation

public struct BetaAnalyticsReportUserActor: Codable, Hashable, Sendable {
    /// True when the account has been deleted, or when the user is no longer a member
    /// of the organization or its associated organizations (for example, their
    /// membership was removed or they were deprovisioned via your identity provider).
    /// `email_address` stays populated for removed users and is null when the account
    /// has been deleted. `name` follows the rules described on that field. The
    /// `user_id` is still populated for reconciliation.
    public var deleted: Bool
    /// The user's current email address, including for users who are no longer members
    /// of the organization. Null when the account has been deleted and for
    /// system-minted service accounts.
    public var emailAddress: String?
    /// The user's current full name.
    ///
    /// Null when the user has not set one. `"Deleted User"` when the account has been
    /// deleted, or when the user is no longer a member and the organization hides
    /// removed users' names.
    public var name: String?
    /// Actor type. Always `"user_actor"`.
    public var type: String
    /// Tagged user ID.
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
