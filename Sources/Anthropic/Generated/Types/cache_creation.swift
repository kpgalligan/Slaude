// Transformed from `anthropic.types.cache_creation` (cache_creation.py).

import Foundation

public struct CacheCreation: Codable, Hashable, Sendable {
    /// The number of input tokens used to create the 1 hour cache entry.
    public var ephemeral1hInputTokens: Int
    /// The number of input tokens used to create the 5 minute cache entry.
    public var ephemeral5mInputTokens: Int

    public init(ephemeral1hInputTokens: Int, ephemeral5mInputTokens: Int) {
        self.ephemeral1hInputTokens = ephemeral1hInputTokens
        self.ephemeral5mInputTokens = ephemeral5mInputTokens
    }

    enum CodingKeys: String, CodingKey {
        case ephemeral1hInputTokens = "ephemeral_1h_input_tokens"
        case ephemeral5mInputTokens = "ephemeral_5m_input_tokens"
    }
}
