// Transformed from `anthropic.types.beta.beta_raw_message_start_event` (beta_raw_message_start_event.py).

import Foundation

public struct BetaRawMessageStartEvent: Codable, Hashable, Sendable {
    public var message: BetaMessage
    public var type: String

    public init(message: BetaMessage, type: String = "message_start") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
