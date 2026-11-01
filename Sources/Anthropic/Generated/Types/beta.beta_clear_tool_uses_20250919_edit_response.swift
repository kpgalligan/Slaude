// Transformed from `anthropic.types.beta.beta_clear_tool_uses_20250919_edit_response` (beta_clear_tool_uses_20250919_edit_response.py).

import Foundation

public struct BetaClearToolUses20250919EditResponse: Codable, Hashable, Sendable {
    /// Number of input tokens cleared by this edit.
    public var clearedInputTokens: Int
    /// Number of tool uses that were cleared.
    public var clearedToolUses: Int
    /// The type of context management edit applied.
    public var type: String

    public init(clearedInputTokens: Int, clearedToolUses: Int, type: String = "clear_tool_uses_20250919") {
        self.clearedInputTokens = clearedInputTokens
        self.clearedToolUses = clearedToolUses
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case clearedInputTokens = "cleared_input_tokens"
        case clearedToolUses = "cleared_tool_uses"
        case type
    }
}
