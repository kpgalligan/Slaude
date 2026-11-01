// Transformed from `anthropic.types.browser_hold_key_tool_use_block` (browser_hold_key_tool_use_block.py).

import Foundation

public struct BrowserHoldKeyToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Hold a key or key chord down for a duration, then release it.
    ///
    /// Uses the same key names and "+" chord syntax as the key action.
    public var input: BrowserHoldKeyInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserHoldKeyInput, name: String = "hold_key", toolsetName: String = "browser", type: String = "tool_use") {
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
