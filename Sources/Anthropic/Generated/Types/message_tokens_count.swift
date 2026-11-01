// Transformed from `anthropic.types.message_tokens_count` (message_tokens_count.py).

import Foundation

public struct MessageTokensCount: Codable, Hashable, Sendable {
    /// The total number of tokens across the provided list of messages, system prompt,
    /// and tools.
    public var inputTokens: Int

    public init(inputTokens: Int) {
        self.inputTokens = inputTokens
    }

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
    }
}
