// Transformed from `anthropic.types.thinking_delta` (thinking_delta.py).

import Foundation

public struct ThinkingDelta: Codable, Hashable, Sendable {
    /// The incremental `thinking` text for this content block.
    ///
    /// Concatenate the `thinking` values of successive `thinking_delta` events to
    /// assemble the block's full `thinking` value.
    public var thinking: String
    public var type: String

    public init(thinking: String, type: String = "thinking_delta") {
        self.thinking = thinking
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case thinking
        case type
    }
}
