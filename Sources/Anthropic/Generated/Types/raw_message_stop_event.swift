// Transformed from `anthropic.types.raw_message_stop_event` (raw_message_stop_event.py).

import Foundation

public struct RawMessageStopEvent: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "message_stop") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
