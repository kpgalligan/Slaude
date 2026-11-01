// Transformed from `anthropic.types.beta.organization.beta_spend_limit_period` (beta_spend_limit_period.py).

import Foundation

public enum BetaSpendLimitPeriod: OpenEnum, CaseIterable {
    case daily
    case monthly
    case weekly
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaSpendLimitPeriod] = [.daily, .monthly, .weekly]

    public init(rawValue: String) {
        switch rawValue {
        case "daily": self = .daily
        case "monthly": self = .monthly
        case "weekly": self = .weekly
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .daily: return "daily"
        case .monthly: return "monthly"
        case .weekly: return "weekly"
        case .unknown(let value): return value
        }
    }
}
