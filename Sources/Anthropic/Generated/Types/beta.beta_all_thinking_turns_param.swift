// Transformed from `anthropic.types.beta.beta_all_thinking_turns_param` (beta_all_thinking_turns_param.py).

import Foundation

public struct BetaAllThinkingTurnsParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
