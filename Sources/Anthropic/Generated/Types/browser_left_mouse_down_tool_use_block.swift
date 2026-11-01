// Transformed from `anthropic.types.browser_left_mouse_down_tool_use_block` (browser_left_mouse_down_tool_use_block.py).

import Foundation

public struct BrowserLeftMouseDownToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Press and hold the left mouse button at a viewport coordinate.
    ///
    /// Pair with left_mouse_up to perform a custom drag.
    public var input: BrowserLeftMouseDownInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserLeftMouseDownInput, name: String = "left_mouse_down", toolsetName: String = "browser", type: String = "tool_use") {
        self.id = id
        self.caller = caller
        self.input = input
        self.name = name
        self.toolsetName = toolsetName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caller
        case input
        case name
        case toolsetName = "toolset_name"
        case type
    }
}
