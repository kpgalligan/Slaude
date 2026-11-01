// Transformed from `anthropic.types.computer_cursor_position_tool_use_block` (computer_cursor_position_tool_use_block.py).

import Foundation

public struct ComputerCursorPositionToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Get the current (x, y) pixel coordinate of the cursor.
    public var input: ComputerCursorPositionInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerCursorPositionInput, name: String = "cursor_position", toolsetName: String = "computer", type: String = "tool_use") {
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
