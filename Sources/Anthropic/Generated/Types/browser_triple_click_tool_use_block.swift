// Transformed from `anthropic.types.browser_triple_click_tool_use_block` (browser_triple_click_tool_use_block.py).

import Foundation

public struct BrowserTripleClickToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Triple left-click at a viewport coordinate or on an element by reference
    /// (typically selects a line or paragraph).
    public var input: BrowserTripleClickInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserTripleClickInput, name: String = "triple_click", toolsetName: String = "browser", type: String = "tool_use") {
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
