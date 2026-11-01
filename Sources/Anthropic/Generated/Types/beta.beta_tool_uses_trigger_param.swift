// Transformed from `anthropic.types.beta.beta_tool_uses_trigger_param` (beta_tool_uses_trigger_param.py).

import Foundation

public struct BetaToolUsesTriggerParam: Codable, Hashable, Sendable {
    public var type: String
    public var value: Int

    public init(type: String = "tool_uses", value: Int) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}
