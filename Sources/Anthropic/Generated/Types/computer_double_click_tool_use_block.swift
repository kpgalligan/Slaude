// Transformed from `anthropic.types.computer_double_click_tool_use_block` (computer_double_click_tool_use_block.py).

import Foundation

public struct ComputerDoubleClickToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Double-click the left mouse button at the specified (x, y) pixel coordinate, or
    /// the current cursor position if `coordinate` is omitted.
    public var input: ComputerDoubleClickInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerDoubleClickInput, name: String = "double_click", toolsetName: String = "computer", type: String = "tool_use") {
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
