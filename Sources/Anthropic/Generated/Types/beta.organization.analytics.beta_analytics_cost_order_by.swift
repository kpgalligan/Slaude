// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_cost_order_by` (beta_analytics_cost_order_by.py).

import Foundation

public enum BetaAnalyticsCostOrderBy: OpenEnum, CaseIterable {
    case amount
    case listAmount
    case time
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsCostOrderBy] = [.amount, .listAmount, .time]

    public init(rawValue: String) {
        switch rawValue {
        case "amount": self = .amount
        case "list_amount": self = .listAmount
        case "time": self = .time
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .amount: return "amount"
        case .listAmount: return "list_amount"
        case .time: return "time"
        case .unknown(let value): return value
        }
    }
}
