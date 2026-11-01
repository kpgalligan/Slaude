// Transformed from `anthropic.types.beta.beta_managed_agents_cache_creation_usage` (beta_managed_agents_cache_creation_usage.py).

import Foundation

/// Prompt-cache creation token usage broken down by cache lifetime.
public struct BetaManagedAgentsCacheCreationUsage: Codable, Hashable, Sendable {
    /// Tokens used to create 1-hour ephemeral cache entries.
    public var ephemeral1hInputTokens: Int?
    /// Tokens used to create 5-minute ephemeral cache entries.
    public var ephemeral5mInputTokens: Int?

    public init(ephemeral1hInputTokens: Int? = nil, ephemeral5mInputTokens: Int? = nil) {
        self.ephemeral1hInputTokens = ephemeral1hInputTokens
        self.ephemeral5mInputTokens = ephemeral5mInputTokens
    }

    enum CodingKeys: String, CodingKey {
        case ephemeral1hInputTokens = "ephemeral_1h_input_tokens"
        case ephemeral5mInputTokens = "ephemeral_5m_input_tokens"
    }
}
