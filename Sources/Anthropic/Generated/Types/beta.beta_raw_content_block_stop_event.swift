// Transformed from `anthropic.types.beta.beta_raw_content_block_stop_event` (beta_raw_content_block_stop_event.py).

import Foundation

public struct BetaRawContentBlockStopEvent: Codable, Hashable, Sendable {
    public var index: Int
    public var type: String

    public init(index: Int, type: String = "content_block_stop") {
        self.index = index
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case index
        case type
    }
}
