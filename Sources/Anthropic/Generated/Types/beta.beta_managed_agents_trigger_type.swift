// Transformed from `anthropic.types.beta.beta_managed_agents_trigger_type` (beta_managed_agents_trigger_type.py).

import Foundation

public enum BetaManagedAgentsTriggerType: OpenEnum, CaseIterable {
    case schedule
    case manual
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsTriggerType] = [.schedule, .manual]

    public init(rawValue: String) {
        switch rawValue {
        case "schedule": self = .schedule
        case "manual": self = .manual
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .schedule: return "schedule"
        case .manual: return "manual"
        case .unknown(let value): return value
        }
    }
}
