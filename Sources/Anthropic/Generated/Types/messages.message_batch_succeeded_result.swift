// Transformed from `anthropic.types.messages.message_batch_succeeded_result` (message_batch_succeeded_result.py).

import Foundation

public struct MessageBatchSucceededResult: Codable, Hashable, Sendable {
    public var message: Message
    public var type: String

    public init(message: Message, type: String = "succeeded") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
