// Transformed from `anthropic.types.beta.organization.spend_limits.increase_request_approve_params` (increase_request_approve_params.py).

import Foundation

public struct IncreaseRequestApproveParams: Codable, Hashable, Sendable {
    /// New per-user spend limit as a non-negative integer decimal string (minor units).
    public var amount: String
    public var period: BetaSpendLimitPeriod??
    public var suppressNotification: Bool?

    public init(amount: String, period: BetaSpendLimitPeriod?? = nil, suppressNotification: Bool? = nil) {
        self.amount = amount
        self.period = period
        self.suppressNotification = suppressNotification
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case period
        case suppressNotification = "suppress_notification"
    }
}
