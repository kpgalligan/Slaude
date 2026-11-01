// Transformed from `anthropic.types.beta.beta_thinking_config_between_tools_param` (beta_thinking_config_between_tools_param.py).

import Foundation

public struct BetaThinkingConfigBetweenToolsParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "between_tools") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
