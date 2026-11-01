// Transformed from `anthropic.types.computer_left_click_drag_tool_use_block` (computer_left_click_drag_tool_use_block.py).

import Foundation

public struct ComputerLeftClickDragToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Click and drag the cursor from `start_coordinate` to `coordinate`.
    public var input: ComputerLeftClickDragInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerLeftClickDragInput, name: String = "left_click_drag", toolsetName: String = "computer", type: String = "tool_use") {
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
