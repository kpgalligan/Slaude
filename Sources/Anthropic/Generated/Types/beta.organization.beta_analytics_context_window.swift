// Transformed from `anthropic.types.beta.organization.beta_analytics_context_window` (beta_analytics_context_window.py).

import Foundation

public enum BetaAnalyticsContextWindow: OpenEnum, CaseIterable {
    case _0_200k
    case _200k1M
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsContextWindow] = [._0_200k, ._200k1M]

    public init(rawValue: String) {
        switch rawValue {
        case "0-200k": self = ._0_200k
        case "200k-1M": self = ._200k1M
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case ._0_200k: return "0-200k"
        case ._200k1M: return "200k-1M"
        case .unknown(let value): return value
        }
    }
}
