// Transformed from `anthropic.types.beta.beta_thinking_turns_param` (beta_thinking_turns_param.py).

import Foundation

public struct BetaThinkingTurnsParam: Codable, Hashable, Sendable {
    public var type: String
    public var value: Int

    public init(type: String = "thinking_turns", value: Int) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}
