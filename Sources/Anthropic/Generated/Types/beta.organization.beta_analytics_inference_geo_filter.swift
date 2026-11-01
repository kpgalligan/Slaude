// Transformed from `anthropic.types.beta.organization.beta_analytics_inference_geo_filter` (beta_analytics_inference_geo_filter.py).

import Foundation

public enum BetaAnalyticsInferenceGeoFilter: OpenEnum, CaseIterable {
    case global
    case notAvailable
    case us
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsInferenceGeoFilter] = [.global, .notAvailable, .us]

    public init(rawValue: String) {
        switch rawValue {
        case "global": self = .global
        case "not_available": self = .notAvailable
        case "us": self = .us
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .global: return "global"
        case .notAvailable: return "not_available"
        case .us: return "us"
        case .unknown(let value): return value
        }
    }
}
