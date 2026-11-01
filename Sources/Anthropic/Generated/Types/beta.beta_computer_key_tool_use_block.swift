// Transformed from `anthropic.types.beta.beta_computer_key_tool_use_block` (beta_computer_key_tool_use_block.py).

import Foundation

public struct BetaComputerKeyToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Press a key or key-combination on the keyboard.
    ///
    /// Use "+" to combine modifiers with a key (e.g. "ctrl+s", "alt+Tab",
    /// "ctrl+shift+Escape"). Key names are case-insensitive; common names like
    /// "Return", "Tab", "Escape", "Up", "Down", "Left", "Right", "Home", "End",
    /// "Page_Up", "Page_Down", "Delete", "BackSpace" are supported.
    public var input: BetaComputerKeyInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerKeyInput, name: String = "key", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
