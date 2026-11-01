// Transformed from `anthropic.types.beta.beta_raw_content_block_delta_event` (beta_raw_content_block_delta_event.py).

import Foundation

public struct BetaRawContentBlockDeltaEvent: Codable, Hashable, Sendable {
    public var delta: BetaRawContentBlockDelta
    public var index: Int
    public var type: String

    public init(delta: BetaRawContentBlockDelta, index: Int, type: String = "content_block_delta") {
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
