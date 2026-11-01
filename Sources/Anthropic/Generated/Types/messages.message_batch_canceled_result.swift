// Transformed from `anthropic.types.messages.message_batch_canceled_result` (message_batch_canceled_result.py).

import Foundation

public struct MessageBatchCanceledResult: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "canceled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
