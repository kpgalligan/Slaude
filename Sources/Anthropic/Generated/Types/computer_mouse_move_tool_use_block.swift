// Transformed from `anthropic.types.computer_mouse_move_tool_use_block` (computer_mouse_move_tool_use_block.py).

import Foundation

public struct ComputerMouseMoveToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Move the cursor to a specified (x, y) pixel coordinate.
    ///
    /// Use this ONLY to hover without clicking; otherwise use a click action directly.
    public var input: ComputerMouseMoveInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerMouseMoveInput, name: String = "mouse_move", toolsetName: String = "computer", type: String = "tool_use") {
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
