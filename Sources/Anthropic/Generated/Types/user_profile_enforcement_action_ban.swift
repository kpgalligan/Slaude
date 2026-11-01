// Transformed from `anthropic.types.user_profile_enforcement_action_ban` (user_profile_enforcement_action_ban.py).

import Foundation

/// Anthropic has stopped serving the end user where the ban applies and does not plan to serve them there again.
public struct UserProfileEnforcementActionBan: Codable, Hashable, Sendable {
    /// The action's ID (`enac_...`), stable while the action is open.
    public var id: String
    /// Always `null`: the end user cannot clear a ban.
    public var action: UserProfileEnforcementActionNextStep?
    /// Always `null`: a ban has no end date.
    public var expiresAt: Date?
    /// When Anthropic opened the action, in RFC 3339 format.
    public var openedAt: Date
    /// Why Anthropic placed the limit: `unsupported_region`, `fraud_or_abuse`,
    /// `high_harm`, `usage_policy_violation`, `account_compromise` or `unspecified`.
    public var reason: UserProfileEnforcementActionReason
    public var type: String

    public init(id: String, action: UserProfileEnforcementActionNextStep? = nil, expiresAt: Date? = nil, openedAt: Date, reason: UserProfileEnforcementActionReason, type: String = "ban") {
        self.id = id
        self.action = action
        self.expiresAt = expiresAt
        self.openedAt = openedAt
        self.reason = reason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case action
        case expiresAt = "expires_at"
        case openedAt = "opened_at"
        case reason
        case type
    }
}
