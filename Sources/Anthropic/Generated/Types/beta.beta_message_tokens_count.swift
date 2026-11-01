// Transformed from `anthropic.types.beta.beta_message_tokens_count` (beta_message_tokens_count.py).

import Foundation

public struct BetaMessageTokensCount: Codable, Hashable, Sendable {
    /// Information about context management applied to the message.
    public var contextManagement: BetaCountTokensContextManagementResponse?
    /// The total number of tokens across the provided list of messages, system prompt,
    /// and tools.
    public var inputTokens: Int

    public init(contextManagement: BetaCountTokensContextManagementResponse? = nil, inputTokens: Int) {
        self.contextManagement = contextManagement
        self.inputTokens = inputTokens
    }

    enum CodingKeys: String, CodingKey {
        case contextManagement = "context_management"
        case inputTokens = "input_tokens"
    }
}
