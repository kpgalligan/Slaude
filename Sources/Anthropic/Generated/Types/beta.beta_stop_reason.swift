// Transformed from `anthropic.types.beta.beta_stop_reason` (beta_stop_reason.py).

import Foundation

public enum BetaStopReason: OpenEnum, CaseIterable {
    case endTurn
    case maxTokens
    case stopSequence
    case toolUse
    case pauseTurn
    case compaction
    case refusal
    case modelContextWindowExceeded
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaStopReason] = [.endTurn, .maxTokens, .stopSequence, .toolUse, .pauseTurn, .compaction, .refusal, .modelContextWindowExceeded]

    public init(rawValue: String) {
        switch rawValue {
        case "end_turn": self = .endTurn
        case "max_tokens": self = .maxTokens
        case "stop_sequence": self = .stopSequence
        case "tool_use": self = .toolUse
        case "pause_turn": self = .pauseTurn
        case "compaction": self = .compaction
        case "refusal": self = .refusal
        case "model_context_window_exceeded": self = .modelContextWindowExceeded
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .endTurn: return "end_turn"
        case .maxTokens: return "max_tokens"
        case .stopSequence: return "stop_sequence"
        case .toolUse: return "tool_use"
        case .pauseTurn: return "pause_turn"
        case .compaction: return "compaction"
        case .refusal: return "refusal"
        case .modelContextWindowExceeded: return "model_context_window_exceeded"
        case .unknown(let value): return value
        }
    }
}
