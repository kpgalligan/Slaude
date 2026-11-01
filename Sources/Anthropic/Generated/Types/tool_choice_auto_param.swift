// Transformed from `anthropic.types.tool_choice_auto_param` (tool_choice_auto_param.py).

import Foundation

/// The model will automatically decide whether to use tools.
public struct ToolChoiceAutoParam: Codable, Hashable, Sendable {
    public var type: String
    /// Whether to disable parallel tool use.
    ///
    /// Defaults to `false`. If set to `true`, the model will output at most one tool
    /// use.
    public var disableParallelToolUse: Bool?

    public init(type: String = "auto", disableParallelToolUse: Bool? = nil) {
        self.type = type
        self.disableParallelToolUse = disableParallelToolUse
    }

    enum CodingKeys: String, CodingKey {
        case type
        case disableParallelToolUse = "disable_parallel_tool_use"
    }
}
