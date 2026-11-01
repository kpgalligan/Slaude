// Transformed from `anthropic.types.beta.organization.beta_spend_limit_usage_tier_scope` (beta_spend_limit_usage_tier_scope.py).

import Foundation

/// Scope of the monthly spend cap Anthropic sets for a Claude Console
/// organization from its usage tier, or a higher cap Anthropic granted the
/// organization. Read-only; its `created_at` and `updated_at` are the
/// organization's creation time, so `amount` can change while `updated_at` stays
/// the same.
public struct BetaSpendLimitUsageTierScope: Codable, Hashable, Sendable {
    /// Scope type. Always `usage_tier` for this scope.
    public var type: String

    public init(type: String = "usage_tier") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
