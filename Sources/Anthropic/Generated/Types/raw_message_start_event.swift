// Transformed from `anthropic.types.raw_message_start_event` (raw_message_start_event.py).

import Foundation

public struct RawMessageStartEvent: Codable, Hashable, Sendable {
    public var message: Message
    public var type: String

    public init(message: Message, type: String = "message_start") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
