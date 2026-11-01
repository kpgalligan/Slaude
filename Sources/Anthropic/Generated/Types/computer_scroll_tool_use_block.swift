// Transformed from `anthropic.types.computer_scroll_tool_use_block` (computer_scroll_tool_use_block.py).

import Foundation

public struct ComputerScrollToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Scroll the screen at the specified (x, y) pixel coordinate, or the current
    /// cursor position if `coordinate` is omitted. Do NOT use PageUp/PageDown to
    /// scroll.
    public var input: ComputerScrollInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerScrollInput, name: String = "scroll", toolsetName: String = "computer", type: String = "tool_use") {
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
