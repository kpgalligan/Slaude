// Transformed from `anthropic.types.beta.beta_computer_right_click_tool_use_block` (beta_computer_right_click_tool_use_block.py).

import Foundation

public struct BetaComputerRightClickToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Click the right mouse button at the specified (x, y) pixel coordinate, or the
    /// current cursor position if `coordinate` is omitted.
    public var input: BetaComputerRightClickInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerRightClickInput, name: String = "right_click", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
