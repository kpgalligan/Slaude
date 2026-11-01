// Transformed from `anthropic.types.raw_content_block_stop_event` (raw_content_block_stop_event.py).

import Foundation

public struct RawContentBlockStopEvent: Codable, Hashable, Sendable {
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
