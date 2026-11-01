// Transformed from `anthropic.types.beta.beta_thinking_prefix_mismatch_behavior` (beta_thinking_prefix_mismatch_behavior.py).

import Foundation

public enum BetaThinkingPrefixMismatchBehavior: OpenEnum, CaseIterable {
    case error
    case dropBlock
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaThinkingPrefixMismatchBehavior] = [.error, .dropBlock]

    public init(rawValue: String) {
        switch rawValue {
        case "error": self = .error
        case "drop_block": self = .dropBlock
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .error: return "error"
        case .dropBlock: return "drop_block"
        case .unknown(let value): return value
        }
    }
}
