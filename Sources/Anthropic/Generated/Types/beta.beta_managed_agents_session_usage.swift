// Transformed from `anthropic.types.beta.beta_managed_agents_session_usage` (beta_managed_agents_session_usage.py).

import Foundation

/// Cumulative token usage for a session across all turns.
public struct BetaManagedAgentsSessionUsage: Codable, Hashable, Sendable {
    /// Cumulative time in seconds during which the session had at least one thread in
    /// running status. Overlapping activity from concurrent threads is counted once,
    /// unlike `stats.active_seconds`, which sums each thread's own active time. This is
    /// the duration the session's runtime cost is priced on.
    public var activeSeconds: Double?
    /// Tokens used to create prompt cache entries, broken down by cache TTL.
    public var cacheCreation: BetaManagedAgentsCacheCreationUsage?
    /// Total tokens read from prompt cache.
    public var cacheReadInputTokens: Int?
    /// Total input tokens consumed across all turns.
    public var inputTokens: Int?
    /// Cumulative list cost of the session across all turns, priced at public list
    /// rates. Absent until cost tracking is available for the session.
    public var listCost: BetaMonetaryAmount?
    /// Total output tokens generated across all turns.
    public var outputTokens: Int?
    /// Cumulative server-executed tool usage across all turns.
    ///
    /// Absent until server-tool tracking is available for the session.
    public var serverToolUse: BetaManagedAgentsServerToolUsage?

    public init(activeSeconds: Double? = nil, cacheCreation: BetaManagedAgentsCacheCreationUsage? = nil, cacheReadInputTokens: Int? = nil, inputTokens: Int? = nil, listCost: BetaMonetaryAmount? = nil, outputTokens: Int? = nil, serverToolUse: BetaManagedAgentsServerToolUsage? = nil) {
        self.activeSeconds = activeSeconds
        self.cacheCreation = cacheCreation
        self.cacheReadInputTokens = cacheReadInputTokens
        self.inputTokens = inputTokens
        self.listCost = listCost
        self.outputTokens = outputTokens
        self.serverToolUse = serverToolUse
    }

    enum CodingKeys: String, CodingKey {
        case activeSeconds = "active_seconds"
        case cacheCreation = "cache_creation"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case inputTokens = "input_tokens"
        case listCost = "list_cost"
        case outputTokens = "output_tokens"
        case serverToolUse = "server_tool_use"
    }
}
