// Transformed from `anthropic.types.beta.organization.beta_analytics_speed` (beta_analytics_speed.py).

import Foundation

public enum BetaAnalyticsSpeed: OpenEnum, CaseIterable {
    case fast
    case standard
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsSpeed] = [.fast, .standard]

    public init(rawValue: String) {
        switch rawValue {
        case "fast": self = .fast
        case "standard": self = .standard
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .fast: return "fast"
        case .standard: return "standard"
        case .unknown(let value): return value
        }
    }
}
