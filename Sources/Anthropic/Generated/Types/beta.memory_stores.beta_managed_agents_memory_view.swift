// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory_view` (beta_managed_agents_memory_view.py).

import Foundation

public enum BetaManagedAgentsMemoryView: OpenEnum, CaseIterable {
    case basic
    case full
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsMemoryView] = [.basic, .full]

    public init(rawValue: String) {
        switch rawValue {
        case "basic": self = .basic
        case "full": self = .full
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .basic: return "basic"
        case .full: return "full"
        case .unknown(let value): return value
        }
    }
}
