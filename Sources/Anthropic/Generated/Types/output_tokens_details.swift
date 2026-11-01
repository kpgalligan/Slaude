// Transformed from `anthropic.types.output_tokens_details` (output_tokens_details.py).

import Foundation

public struct OutputTokensDetails: Codable, Hashable, Sendable {
    /// Number of output tokens the model generated as internal reasoning, including the
    /// thinking-block delimiter tokens.
    ///
    /// Reflects the raw reasoning the model produced, not the (possibly shorter)
    /// summarized thinking text returned in the response body. Computed by
    /// re-tokenizing the raw reasoning text, so it may differ from the model's exact
    /// generation count by a small number of tokens. Always ≤ `output_tokens`;
    /// `output_tokens - thinking_tokens` approximates the non-reasoning output.
    public var thinkingTokens: Int

    public init(thinkingTokens: Int) {
        self.thinkingTokens = thinkingTokens
    }

    enum CodingKeys: String, CodingKey {
        case thinkingTokens = "thinking_tokens"
    }
}
