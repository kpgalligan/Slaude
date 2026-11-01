// Transformed from `anthropic.types.beta.beta_browser_read_page_filter` (beta_browser_read_page_filter.py).

import Foundation

public enum BetaBrowserReadPageFilter: OpenEnum, CaseIterable {
    case all
    case interactive
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaBrowserReadPageFilter] = [.all, .interactive]

    public init(rawValue: String) {
        switch rawValue {
        case "all": self = .all
        case "interactive": self = .interactive
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .all: return "all"
        case .interactive: return "interactive"
        case .unknown(let value): return value
        }
    }
}
