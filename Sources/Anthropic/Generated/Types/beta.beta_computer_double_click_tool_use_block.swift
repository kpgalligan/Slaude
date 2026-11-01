// Transformed from `anthropic.types.beta.beta_computer_double_click_tool_use_block` (beta_computer_double_click_tool_use_block.py).

import Foundation

public struct BetaComputerDoubleClickToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Double-click the left mouse button at the specified (x, y) pixel coordinate, or
    /// the current cursor position if `coordinate` is omitted.
    public var input: BetaComputerDoubleClickInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerDoubleClickInput, name: String = "double_click", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
