// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_usage_order_by` (beta_analytics_usage_order_by.py).

import Foundation

public enum BetaAnalyticsUsageOrderBy: OpenEnum, CaseIterable {
    case outputTokens
    case requests
    case time
    case totalTokens
    case uncachedInputTokens
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsUsageOrderBy] = [.outputTokens, .requests, .time, .totalTokens, .uncachedInputTokens]

    public init(rawValue: String) {
        switch rawValue {
        case "output_tokens": self = .outputTokens
        case "requests": self = .requests
        case "time": self = .time
        case "total_tokens": self = .totalTokens
        case "uncached_input_tokens": self = .uncachedInputTokens
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .outputTokens: return "output_tokens"
        case .requests: return "requests"
        case .time: return "time"
        case .totalTokens: return "total_tokens"
        case .uncachedInputTokens: return "uncached_input_tokens"
        case .unknown(let value): return value
        }
    }
}
