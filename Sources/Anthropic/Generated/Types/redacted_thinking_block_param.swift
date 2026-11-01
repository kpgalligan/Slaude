// Transformed from `anthropic.types.redacted_thinking_block_param` (redacted_thinking_block_param.py).

import Foundation

public struct RedactedThinkingBlockParam: Codable, Hashable, Sendable {
    /// The `data` value of this redacted thinking block, exactly as returned by the API
    /// in a previous response. Opaque and encrypted; pass it back unchanged.
    public var data: String
    public var type: String

    public init(data: String, type: String = "redacted_thinking") {
        self.data = data
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case data
        case type
    }
}
