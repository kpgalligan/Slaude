// Transformed from `anthropic.types.beta.beta_text_delta` (beta_text_delta.py).

import Foundation

public struct BetaTextDelta: Codable, Hashable, Sendable {
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
