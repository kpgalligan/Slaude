// Transformed from `anthropic.types.beta.messages.beta_message_batch_canceled_result` (beta_message_batch_canceled_result.py).

import Foundation

public struct BetaMessageBatchCanceledResult: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "canceled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
