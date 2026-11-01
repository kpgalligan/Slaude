// Transformed from `anthropic.types.beta.beta_browser_scroll_direction` (beta_browser_scroll_direction.py).

import Foundation

public enum BetaBrowserScrollDirection: OpenEnum, CaseIterable {
    case up
    case down
    case left
    case right
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaBrowserScrollDirection] = [.up, .down, .left, .right]

    public init(rawValue: String) {
        switch rawValue {
        case "up": self = .up
        case "down": self = .down
        case "left": self = .left
        case "right": self = .right
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .up: return "up"
        case .down: return "down"
        case .left: return "left"
        case .right: return "right"
        case .unknown(let value): return value
        }
    }
}
