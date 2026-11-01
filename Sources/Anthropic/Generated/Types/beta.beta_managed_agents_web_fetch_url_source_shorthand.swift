// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_shorthand` (beta_managed_agents_web_fetch_url_source_shorthand.py).

import Foundation

public enum BetaManagedAgentsWebFetchURLSourceShorthand: OpenEnum, CaseIterable {
    case all
    case none
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsWebFetchURLSourceShorthand] = [.all, .none]

    public init(rawValue: String) {
        switch rawValue {
        case "all": self = .all
        case "none": self = .none
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .all: return "all"
        case .none: return "none"
        case .unknown(let value): return value
        }
    }
}
