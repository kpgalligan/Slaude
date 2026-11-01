// Transformed from `anthropic.types.beta.organization.beta_analytics_grouped_cost_type` (beta_analytics_grouped_cost_type.py).

import Foundation

public enum BetaAnalyticsGroupedCostType: OpenEnum, CaseIterable {
    case codeExecution
    case sessionUsage
    case tokens
    case webSearch
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsGroupedCostType] = [.codeExecution, .sessionUsage, .tokens, .webSearch]

    public init(rawValue: String) {
        switch rawValue {
        case "code_execution": self = .codeExecution
        case "session_usage": self = .sessionUsage
        case "tokens": self = .tokens
        case "web_search": self = .webSearch
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .codeExecution: return "code_execution"
        case .sessionUsage: return "session_usage"
        case .tokens: return "tokens"
        case .webSearch: return "web_search"
        case .unknown(let value): return value
        }
    }
}
