// Transformed from `anthropic.types.beta.beta_dream_usage` (beta_dream_usage.py).

import Foundation

/// The tokens that a dream has used so far.
///
/// The counts are zero while the dream is `pending` and update while it is `running`. They can keep changing after a cancel.
///
/// See the [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#billing) for how dreams are billed. See the [prompt caching guide](https://platform.claude.com/docs/en/build-with-claude/prompt-caching#tracking-cache-performance) for how the input token counts add up.
public struct BetaDreamUsage: Codable, Hashable, Sendable {
    /// The dream's input tokens that were written to the prompt cache, for both the
    /// 5-minute and 1-hour cache durations.
    public var cacheCreationInputTokens: Int
    /// The dream's input tokens that were read from the prompt cache.
    public var cacheReadInputTokens: Int
    /// The dream's input tokens that weren't read from or written to the prompt cache.
    public var inputTokens: Int
    /// The tokens that the model generated for the dream.
    public var outputTokens: Int

    public init(cacheCreationInputTokens: Int, cacheReadInputTokens: Int, inputTokens: Int, outputTokens: Int) {
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}
