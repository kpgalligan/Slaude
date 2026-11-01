// Transformed from `anthropic.types.message_delta_usage` (message_delta_usage.py).

import Foundation

public struct MessageDeltaUsage: Codable, Hashable, Sendable {
    /// The cumulative number of input tokens used to create the cache entry.
    public var cacheCreationInputTokens: Int?
    /// The cumulative number of input tokens read from the cache.
    public var cacheReadInputTokens: Int?
    /// The cumulative number of input tokens which were used.
    public var inputTokens: Int?
    /// The cumulative number of output tokens which were used.
    public var outputTokens: Int
    /// Breakdown of output tokens by category.
    ///
    /// `output_tokens` remains the inclusive, authoritative total used for billing.
    /// This object provides a read-only decomposition for observability — for example,
    /// how many of the billed output tokens were spent on internal reasoning that may
    /// have been summarized before being returned to you.
    public var outputTokensDetails: OutputTokensDetails?
    /// The number of server tool requests.
    public var serverToolUse: ServerToolUsage?

    public init(cacheCreationInputTokens: Int? = nil, cacheReadInputTokens: Int? = nil, inputTokens: Int? = nil, outputTokens: Int, outputTokensDetails: OutputTokensDetails? = nil, serverToolUse: ServerToolUsage? = nil) {
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.outputTokensDetails = outputTokensDetails
        self.serverToolUse = serverToolUse
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case outputTokensDetails = "output_tokens_details"
        case serverToolUse = "server_tool_use"
    }
}
