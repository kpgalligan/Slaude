// Transformed from `anthropic.types.thinking_config_disabled_param` (thinking_config_disabled_param.py).

import Foundation

public struct ThinkingConfigDisabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
