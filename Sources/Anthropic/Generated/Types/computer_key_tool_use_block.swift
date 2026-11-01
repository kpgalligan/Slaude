// Transformed from `anthropic.types.computer_key_tool_use_block` (computer_key_tool_use_block.py).

import Foundation

public struct ComputerKeyToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Press a key or key-combination on the keyboard.
    ///
    /// Use "+" to combine modifiers with a key (e.g. "ctrl+s", "alt+Tab",
    /// "ctrl+shift+Escape"). Key names are case-insensitive; common names like
    /// "Return", "Tab", "Escape", "Up", "Down", "Left", "Right", "Home", "End",
    /// "Page_Up", "Page_Down", "Delete", "BackSpace" are supported.
    public var input: ComputerKeyInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerKeyInput, name: String = "key", toolsetName: String = "computer", type: String = "tool_use") {
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
