// Transformed from `anthropic.types.raw_content_block_delta_event` (raw_content_block_delta_event.py).

import Foundation

public struct RawContentBlockDeltaEvent: Codable, Hashable, Sendable {
    public var delta: RawContentBlockDelta
    public var index: Int
    public var type: String

    public init(delta: RawContentBlockDelta, index: Int, type: String = "content_block_delta") {
        self.delta = delta
        self.index = index
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case delta
        case index
        case type
    }
}
