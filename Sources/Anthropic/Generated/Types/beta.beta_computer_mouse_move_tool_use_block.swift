// Transformed from `anthropic.types.beta.beta_computer_mouse_move_tool_use_block` (beta_computer_mouse_move_tool_use_block.py).

import Foundation

public struct BetaComputerMouseMoveToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Move the cursor to a specified (x, y) pixel coordinate.
    ///
    /// Use this ONLY to hover without clicking; otherwise use a click action directly.
    public var input: BetaComputerMouseMoveInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerMouseMoveInput, name: String = "mouse_move", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
