// Transformed from `anthropic.types.beta.beta_computer_left_click_drag_tool_use_block` (beta_computer_left_click_drag_tool_use_block.py).

import Foundation

public struct BetaComputerLeftClickDragToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Click and drag the cursor from `start_coordinate` to `coordinate`.
    public var input: BetaComputerLeftClickDragInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerLeftClickDragInput, name: String = "left_click_drag", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
