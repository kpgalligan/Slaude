// Transformed from `anthropic.types.messages.message_batch_expired_result` (message_batch_expired_result.py).

import Foundation

public struct MessageBatchExpiredResult: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "expired") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
