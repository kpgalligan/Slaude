// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_usage` (beta_managed_agents_session_thread_usage.py).

import Foundation

/// Cumulative token usage for a session thread across all turns.
public struct BetaManagedAgentsSessionThreadUsage: Codable, Hashable, Sendable {
    /// Cumulative time in seconds this thread spent in running status.
    ///
    /// Equal to `stats.active_seconds`; surfaced here so a thread's usage carries every
    /// quantity its cost is priced on.
    public var activeSeconds: Double?
    /// Tokens used to create prompt cache entries, broken down by cache TTL.
    public var cacheCreation: BetaManagedAgentsCacheCreationUsage?
    /// Total tokens read from prompt cache.
    public var cacheReadInputTokens: Int?
    /// Total input tokens consumed across all turns.
    public var inputTokens: Int?
    /// Cumulative list cost of this thread across all turns, priced at public list
    /// rates. Absent until cost tracking is available for the thread. Each figure is
    /// rounded to the nearest cent independently and the session's aggregate
    /// `usage.list_cost` additionally includes session runtime, so per-thread costs do
    /// not sum exactly to the session figure; the session figure is authoritative and
    /// is what a budget is enforced against.
    public var listCost: BetaMonetaryAmount?
    /// Total output tokens generated across all turns.
    public var outputTokens: Int?
    /// Cumulative server-executed tool usage across all turns of this thread.
    ///
    /// Absent until server-tool tracking is available for the thread.
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
