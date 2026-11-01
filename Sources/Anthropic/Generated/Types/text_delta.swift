// Transformed from `anthropic.types.text_delta` (text_delta.py).

import Foundation

public struct TextDelta: Codable, Hashable, Sendable {
    public var text: String
    public var type: String

    public init(text: String, type: String = "text_delta") {
        self.text = text
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
    }
}
