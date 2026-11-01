// Transformed from `anthropic.types.beta.beta_tool_choice_auto_param` (beta_tool_choice_auto_param.py).

import Foundation

/// The model will automatically decide whether to use tools.
public struct BetaToolChoiceAutoParam: Codable, Hashable, Sendable {
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
