// Transformed from `anthropic.types.computer_hold_key_tool_use_block` (computer_hold_key_tool_use_block.py).

import Foundation

public struct ComputerHoldKeyToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Hold down a key or key-combination for a specified duration.
    ///
    /// Uses the same key syntax as `key`.
    public var input: ComputerHoldKeyInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: ComputerHoldKeyInput, name: String = "hold_key", toolsetName: String = "computer", type: String = "tool_use") {
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
