// Transformed from `anthropic.types.beta.organization.beta_spend_limit_seat_tier_scope` (beta_spend_limit_seat_tier_scope.py).

import Foundation

public struct BetaSpendLimitSeatTierScope: Codable, Hashable, Sendable {
    public var seatTier: String
    public var type: String

    public init(seatTier: String, type: String = "seat_tier") {
        self.seatTier = seatTier
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case seatTier = "seat_tier"
        case type
    }
}
