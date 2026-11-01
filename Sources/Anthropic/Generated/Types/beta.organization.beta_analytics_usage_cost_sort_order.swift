// Transformed from `anthropic.types.beta.organization.beta_analytics_usage_cost_sort_order` (beta_analytics_usage_cost_sort_order.py).

import Foundation

public enum BetaAnalyticsUsageCostSortOrder: OpenEnum, CaseIterable {
    case asc
    case desc
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsUsageCostSortOrder] = [.asc, .desc]

    public init(rawValue: String) {
        switch rawValue {
        case "asc": self = .asc
        case "desc": self = .desc
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .asc: return "asc"
        case .desc: return "desc"
        case .unknown(let value): return value
        }
    }
}
