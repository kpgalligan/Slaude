// Transformed from `anthropic.types.user_profile_enforcement_action_restriction` (user_profile_enforcement_action_restriction.py).

import Foundation

/// Anthropic has limited how it serves the end user until the action is resolved.
///
/// The end user may still be served in part.
public struct UserProfileEnforcementActionRestriction: Codable, Hashable, Sendable {
    /// The action's ID (`enac_...`), stable while the action is open.
    public var id: String
    /// The next step on the action: `verify` or `null`.
    ///
    /// `verify`: the end user can clear it now by passing an identity check. `null`:
    /// there is nothing the end user can do now to clear it, including while Anthropic
    /// reviews an identity check the end user submitted.
    public var action: UserProfileEnforcementActionNextStep?
    /// When the action ends on its own, in RFC 3339 format; it stops showing once this
    /// time has passed. `null` when it has no end date, and always `null` when `reason`
    /// is `account_compromise`.
    public var expiresAt: Date?
    /// When Anthropic opened the action, in RFC 3339 format.
    public var openedAt: Date
    /// Why Anthropic placed the limit: `unsupported_region`, `fraud_or_abuse`,
    /// `high_harm`, `usage_policy_violation`, `account_compromise` or `unspecified`.
    public var reason: UserProfileEnforcementActionReason
    public var type: String

    public init(id: String, action: UserProfileEnforcementActionNextStep? = nil, expiresAt: Date? = nil, openedAt: Date, reason: UserProfileEnforcementActionReason, type: String = "restriction") {
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
