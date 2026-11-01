// Transformed from `anthropic.types.beta.beta_computer_scroll_direction` (beta_computer_scroll_direction.py).

import Foundation

public enum BetaComputerScrollDirection: OpenEnum, CaseIterable {
    case up
    case down
    case left
    case right
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaComputerScrollDirection] = [.up, .down, .left, .right]

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
