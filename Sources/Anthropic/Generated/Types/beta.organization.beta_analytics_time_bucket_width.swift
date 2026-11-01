// Transformed from `anthropic.types.beta.organization.beta_analytics_time_bucket_width` (beta_analytics_time_bucket_width.py).

import Foundation

public enum BetaAnalyticsTimeBucketWidth: OpenEnum, CaseIterable {
    case _1d
    case _1h
    case _1m
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsTimeBucketWidth] = [._1d, ._1h, ._1m]

    public init(rawValue: String) {
        switch rawValue {
        case "1d": self = ._1d
        case "1h": self = ._1h
        case "1m": self = ._1m
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case ._1d: return "1d"
        case ._1h: return "1h"
        case ._1m: return "1m"
        case .unknown(let value): return value
        }
    }
}
