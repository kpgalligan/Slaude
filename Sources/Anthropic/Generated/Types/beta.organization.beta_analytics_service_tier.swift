// Transformed from `anthropic.types.beta.organization.beta_analytics_service_tier` (beta_analytics_service_tier.py).

import Foundation

public enum BetaAnalyticsServiceTier: OpenEnum, CaseIterable {
    case batch
    case flex
    case flexDiscount
    case priority
    case priorityOnDemand
    case standard
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsServiceTier] = [.batch, .flex, .flexDiscount, .priority, .priorityOnDemand, .standard]

    public init(rawValue: String) {
        switch rawValue {
        case "batch": self = .batch
        case "flex": self = .flex
        case "flex_discount": self = .flexDiscount
        case "priority": self = .priority
        case "priority_on_demand": self = .priorityOnDemand
        case "standard": self = .standard
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .batch: return "batch"
        case .flex: return "flex"
        case .flexDiscount: return "flex_discount"
        case .priority: return "priority"
        case .priorityOnDemand: return "priority_on_demand"
        case .standard: return "standard"
        case .unknown(let value): return value
        }
    }
}
