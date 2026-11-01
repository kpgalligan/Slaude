// Transformed from `anthropic.types.beta.beta_clear_thinking_20251015_edit_response` (beta_clear_thinking_20251015_edit_response.py).

import Foundation

public struct BetaClearThinking20251015EditResponse: Codable, Hashable, Sendable {
    /// Number of input tokens cleared by this edit.
    public var clearedInputTokens: Int
    /// Number of thinking turns that were cleared.
    public var clearedThinkingTurns: Int
    /// The type of context management edit applied.
    public var type: String

    public init(clearedInputTokens: Int, clearedThinkingTurns: Int, type: String = "clear_thinking_20251015") {
        self.clearedInputTokens = clearedInputTokens
        self.clearedThinkingTurns = clearedThinkingTurns
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case clearedInputTokens = "cleared_input_tokens"
        case clearedThinkingTurns = "cleared_thinking_turns"
        case type
    }
}
