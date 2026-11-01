// Transformed from `anthropic.types.tool_choice_any_param` (tool_choice_any_param.py).

import Foundation

/// The model will use any available tools.
public struct ToolChoiceAnyParam: Codable, Hashable, Sendable {
    public var type: String
    /// Whether to disable parallel tool use.
    ///
    /// Defaults to `false`. If set to `true`, the model will output exactly one tool
    /// use.
    public var disableParallelToolUse: Bool?

    public init(type: String = "any", disableParallelToolUse: Bool? = nil) {
        self.type = type
        self.disableParallelToolUse = disableParallelToolUse
    }

    enum CodingKeys: String, CodingKey {
        case type
        case disableParallelToolUse = "disable_parallel_tool_use"
    }
}
