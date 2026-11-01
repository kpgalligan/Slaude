// Transformed from `anthropic.types.browser_read_page_filter` (browser_read_page_filter.py).

import Foundation

public enum BrowserReadPageFilter: OpenEnum, CaseIterable {
    case all
    case interactive
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BrowserReadPageFilter] = [.all, .interactive]

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
