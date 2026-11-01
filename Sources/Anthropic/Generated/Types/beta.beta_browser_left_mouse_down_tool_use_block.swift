// Transformed from `anthropic.types.beta.beta_browser_left_mouse_down_tool_use_block` (beta_browser_left_mouse_down_tool_use_block.py).

import Foundation

public struct BetaBrowserLeftMouseDownToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Press and hold the left mouse button at a viewport coordinate.
    ///
    /// Pair with left_mouse_up to perform a custom drag.
    public var input: BetaBrowserLeftMouseDownInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserLeftMouseDownInput, name: String = "left_mouse_down", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
        self.id = id
        self.input = input
        self.name = name
        self.toolsetName = toolsetName
        self.type = type
        self.caller = caller
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case name
        case toolsetName = "toolset_name"
        case type
        case caller
    }
}
