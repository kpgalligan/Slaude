// Transformed from `anthropic.types.beta.messages.beta_message_batch_expired_result` (beta_message_batch_expired_result.py).

import Foundation

public struct BetaMessageBatchExpiredResult: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "expired") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
