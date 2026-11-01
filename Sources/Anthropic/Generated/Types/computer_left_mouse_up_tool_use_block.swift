// Transformed from `anthropic.types.computer_left_mouse_up_tool_use_block` (computer_left_mouse_up_tool_use_block.py).

import Foundation

public struct ComputerLeftMouseUpToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Release the left mouse button.
    public var input: ComputerLeftMouseUpInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerLeftMouseUpInput, name: String = "left_mouse_up", toolsetName: String = "computer", type: String = "tool_use") {
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
