// Transformed from `anthropic.types.beta.beta_thinking_config_disabled_param` (beta_thinking_config_disabled_param.py).

import Foundation

public struct BetaThinkingConfigDisabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
