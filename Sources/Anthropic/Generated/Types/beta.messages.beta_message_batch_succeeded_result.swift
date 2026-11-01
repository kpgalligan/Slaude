// Transformed from `anthropic.types.beta.messages.beta_message_batch_succeeded_result` (beta_message_batch_succeeded_result.py).

import Foundation

public struct BetaMessageBatchSucceededResult: Codable, Hashable, Sendable {
    public var message: BetaMessage
    public var type: String

    public init(message: BetaMessage, type: String = "succeeded") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
