// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_usage_metrics` (beta_analytics_usage_metrics.py).

import Foundation

/// The token usage of one row.
public struct BetaAnalyticsUsageMetrics: Codable, Hashable, Sendable {
    /// The number of input tokens for cache creation.
    public var cacheCreation: BetaCacheCreation
    /// The number of input tokens read from the cache.
    public var cacheReadInputTokens: Int
    /// The number of output tokens generated.
    public var outputTokens: Int
    /// Number of API requests in this row's scope.
    ///
    /// For sandbox / code-execution events, this counts execution spans rather than
    /// HTTP requests (these rows surface with `product: null`).
    public var requests: Int?
    /// Server-side tool usage metrics.
    public var serverToolUse: BetaAnalyticsServerToolUse
    /// Total token count across all token types.
    ///
    /// This is the value the default `order_by` (`total_tokens`) sorts on.
    public var totalTokens: Int
    /// The number of uncached input tokens processed.
    public var uncachedInputTokens: Int

    public init(cacheCreation: BetaCacheCreation, cacheReadInputTokens: Int, outputTokens: Int, requests: Int? = nil, serverToolUse: BetaAnalyticsServerToolUse, totalTokens: Int, uncachedInputTokens: Int) {
        self.cacheCreation = cacheCreation
        self.cacheReadInputTokens = cacheReadInputTokens
        self.outputTokens = outputTokens
        self.requests = requests
        self.serverToolUse = serverToolUse
        self.totalTokens = totalTokens
        self.uncachedInputTokens = uncachedInputTokens
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreation = "cache_creation"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case outputTokens = "output_tokens"
        case requests
        case serverToolUse = "server_tool_use"
        case totalTokens = "total_tokens"
        case uncachedInputTokens = "uncached_input_tokens"
    }
}
