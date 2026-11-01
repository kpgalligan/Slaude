// Transformed from `anthropic.types.beta.beta_message_delta_usage` (beta_message_delta_usage.py).

import Foundation

public struct BetaMessageDeltaUsage: Codable, Hashable, Sendable {
    /// The cumulative number of input tokens used to create the cache entry.
    public var cacheCreationInputTokens: Int?
    /// The cumulative number of input tokens read from the cache.
    public var cacheReadInputTokens: Int?
    /// Outcome of the `fallback_credit_token` presented on this request.
    ///
    /// Present on every response to a non-batch request that carried a
    /// `fallback_credit_token`, in either redemption mode; absent otherwise (batch
    /// items accept and ignore the token and carry no outcome object).
    public var fallbackCredit: BetaFallbackCreditUsage?
    /// The cumulative number of input tokens which were used.
    public var inputTokens: Int?
    /// Per-iteration token usage breakdown.
    ///
    /// Each entry represents one sampling iteration, with its own input/output token
    /// counts and cache statistics, discriminated by `type`. For `message` entries
    /// (model sampling iterations, such as the turns of a server-side tool use loop),
    /// this allows you to:
    ///
    /// - Calculate the context window size from the last `message` entry
    /// - Understand token accumulation across server-side tool use loops
    ///
    /// A `compaction` entry reports the token usage of the compaction operation itself
    /// — the server-side request that summarizes the context being closed — NOT the
    /// size of the context that was compacted away, and its token counts can be much
    /// smaller than that closed context (for example, a compaction that closes a
    /// ~200k-token context can report only a few thousand tokens). Do not derive the
    /// context window size from a `compaction` entry, even when it is the last entry. A
    /// `compaction` entry's tokens are not included in the top-level `usage` fields.
    /// When an input-token trigger is in effect (the default — 150,000 tokens unless
    /// configured otherwise), each `compaction` entry closes a context that had reached
    /// at least that threshold, though the context can exceed it by the final
    /// iteration's output and tool results.
    public var iterations: BetaIterationsUsage?
    /// The cumulative number of output tokens which were used.
    public var outputTokens: Int
    /// Breakdown of output tokens by category.
    ///
    /// `output_tokens` remains the inclusive, authoritative total used for billing.
    /// This object provides a read-only decomposition for observability — for example,
    /// how many of the billed output tokens were spent on internal reasoning that may
    /// have been summarized before being returned to you.
    public var outputTokensDetails: BetaOutputTokensDetails?
    /// The number of server tool requests.
    public var serverToolUse: BetaServerToolUsage?

    public init(cacheCreationInputTokens: Int? = nil, cacheReadInputTokens: Int? = nil, fallbackCredit: BetaFallbackCreditUsage? = nil, inputTokens: Int? = nil, iterations: BetaIterationsUsage? = nil, outputTokens: Int, outputTokensDetails: BetaOutputTokensDetails? = nil, serverToolUse: BetaServerToolUsage? = nil) {
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.fallbackCredit = fallbackCredit
        self.inputTokens = inputTokens
        self.iterations = iterations
        self.outputTokens = outputTokens
        self.outputTokensDetails = outputTokensDetails
        self.serverToolUse = serverToolUse
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case fallbackCredit = "fallback_credit"
        case inputTokens = "input_tokens"
        case iterations
        case outputTokens = "output_tokens"
        case outputTokensDetails = "output_tokens_details"
        case serverToolUse = "server_tool_use"
    }
}
