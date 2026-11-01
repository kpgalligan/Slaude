// Transformed from `anthropic.types.beta.beta_model_line` (beta_model_line.py).

import Foundation

public enum BetaModelLine: OpenEnum, CaseIterable {
    case haiku
    case sonnet
    case opus
    case fable
    case mythos
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaModelLine] = [.haiku, .sonnet, .opus, .fable, .mythos]

    public init(rawValue: String) {
        switch rawValue {
        case "haiku": self = .haiku
        case "sonnet": self = .sonnet
        case "opus": self = .opus
        case "fable": self = .fable
        case "mythos": self = .mythos
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .haiku: return "haiku"
        case .sonnet: return "sonnet"
        case .opus: return "opus"
        case .fable: return "fable"
        case .mythos: return "mythos"
        case .unknown(let value): return value
        }
    }
}
