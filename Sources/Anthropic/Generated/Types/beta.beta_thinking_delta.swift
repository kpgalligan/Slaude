// Transformed from `anthropic.types.beta.beta_thinking_delta` (beta_thinking_delta.py).

import Foundation

public struct BetaThinkingDelta: Codable, Hashable, Sendable {
    /// Per-frame increment of a coarse, running estimate of the tokens this thinking
    /// block has produced so far. Present whenever the
    /// `thinking-token-count-2026-05-13` beta is set; `null` unless `thinking.display`
    /// resolves to `"omitted"` and a count is due this frame. Sum the increments across
    /// `thinking_delta` frames on this block for a progress indicator. Each increment
    /// is a non-negative multiple of a fixed quantum and the cadence is rate-limited,
    /// so this is a deliberately lossy display hint, not a billable count;
    /// `usage.output_tokens` remains authoritative.
    public var estimatedTokens: Int?
    /// The incremental `thinking` text for this content block.
    ///
    /// Concatenate the `thinking` values of successive `thinking_delta` events to
    /// assemble the block's full `thinking` value.
    public var thinking: String
    public var type: String

    public init(estimatedTokens: Int? = nil, thinking: String, type: String = "thinking_delta") {
        self.estimatedTokens = estimatedTokens
        self.thinking = thinking
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case estimatedTokens = "estimated_tokens"
        case thinking
        case type
    }
}
