// Transformed from `anthropic.types.browser_mouse_move_tool_use_block` (browser_mouse_move_tool_use_block.py).

import Foundation

public struct BrowserMouseMoveToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Move the pointer to a viewport coordinate without clicking.
    public var input: BrowserMouseMoveInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserMouseMoveInput, name: String = "mouse_move", toolsetName: String = "browser", type: String = "tool_use") {
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
