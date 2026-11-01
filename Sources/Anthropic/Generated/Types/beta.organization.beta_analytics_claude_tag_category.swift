// Transformed from `anthropic.types.beta.organization.beta_analytics_claude_tag_category` (beta_analytics_claude_tag_category.py).

import Foundation

public enum BetaAnalyticsClaudeTagCategory: OpenEnum, CaseIterable {
    case dm
    case engaged
    case monitoring
    case proactive
    case scheduled
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsClaudeTagCategory] = [.dm, .engaged, .monitoring, .proactive, .scheduled]

    public init(rawValue: String) {
        switch rawValue {
        case "dm": self = .dm
        case "engaged": self = .engaged
        case "monitoring": self = .monitoring
        case "proactive": self = .proactive
        case "scheduled": self = .scheduled
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .dm: return "dm"
        case .engaged: return "engaged"
        case .monitoring: return "monitoring"
        case .proactive: return "proactive"
        case .scheduled: return "scheduled"
        case .unknown(let value): return value
        }
    }
}
