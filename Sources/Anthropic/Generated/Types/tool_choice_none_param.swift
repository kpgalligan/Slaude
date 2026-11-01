// Transformed from `anthropic.types.tool_choice_none_param` (tool_choice_none_param.py).

import Foundation

/// The model will not be allowed to use tools.
public struct ToolChoiceNoneParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
