// Transformed from `anthropic.types.beta.beta_compaction_iteration_usage` (beta_compaction_iteration_usage.py).

import Foundation

/// Token usage for a compaction iteration.
public struct BetaCompactionIterationUsage: Codable, Hashable, Sendable {
    /// Breakdown of cached tokens by TTL
    public var cacheCreation: BetaCacheCreation?
    /// The number of input tokens used to create the cache entry.
    public var cacheCreationInputTokens: Int
    /// The number of input tokens read from the cache.
    public var cacheReadInputTokens: Int
    /// The number of input tokens which were used.
    public var inputTokens: Int
    /// The number of output tokens which were used.
    public var outputTokens: Int
    /// Usage for a compaction iteration
    public var type: String

    public init(cacheCreation: BetaCacheCreation? = nil, cacheCreationInputTokens: Int, cacheReadInputTokens: Int, inputTokens: Int, outputTokens: Int, type: String = "compaction") {
        self.cacheCreation = cacheCreation
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreation = "cache_creation"
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case type
    }
}
