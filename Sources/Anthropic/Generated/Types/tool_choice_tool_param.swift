// Transformed from `anthropic.types.tool_choice_tool_param` (tool_choice_tool_param.py).

import Foundation

/// The model will use the specified tool with `tool_choice.name`.
public struct ToolChoiceToolParam: Codable, Hashable, Sendable {
    /// The name of the tool to use.
    public var name: String
    public var type: String
    /// Whether to disable parallel tool use.
    ///
    /// Defaults to `false`. If set to `true`, the model will output exactly one tool
    /// use.
    public var disableParallelToolUse: Bool?

    public init(name: String, type: String = "tool", disableParallelToolUse: Bool? = nil) {
        self.name = name
        self.type = type
        self.disableParallelToolUse = disableParallelToolUse
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case disableParallelToolUse = "disable_parallel_tool_use"
    }
}
