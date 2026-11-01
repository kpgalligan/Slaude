// Transformed from `anthropic.types.beta.beta_raw_message_stop_event` (beta_raw_message_stop_event.py).

import Foundation

public struct BetaRawMessageStopEvent: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "message_stop") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
