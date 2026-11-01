// Transformed from `anthropic.types.thinking_config_between_tools_param` (thinking_config_between_tools_param.py).

import Foundation

public struct ThinkingConfigBetweenToolsParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "between_tools") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
