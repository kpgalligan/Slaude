// Transformed from `anthropic.types.beta.beta_count_tokens_context_management_response` (beta_count_tokens_context_management_response.py).

import Foundation

public struct BetaCountTokensContextManagementResponse: Codable, Hashable, Sendable {
    /// The original token count before context management was applied
    public var originalInputTokens: Int

    public init(originalInputTokens: Int) {
        self.originalInputTokens = originalInputTokens
    }

    enum CodingKeys: String, CodingKey {
        case originalInputTokens = "original_input_tokens"
    }
}
