// Transformed from `anthropic.types.redacted_thinking_block` (redacted_thinking_block.py).

import Foundation

public struct RedactedThinkingBlock: Codable, Hashable, Sendable {
    /// The contents of this redacted thinking block, returned when portions of the
    /// model's thinking were safety-redacted. This field is opaque and encrypted, with
    /// no readable content.
    ///
    /// Pass `redacted_thinking` blocks back to the API unchanged when continuing a
    /// multi-turn conversation.
    ///
    /// See
    /// [extended thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking#redacted-thinking-blocks)
    /// for details.
    public var data: String
    public var type: String

    public init(data: String, type: String = "redacted_thinking") {
        self.data = data
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case data
        case type
    }
}
