// Transformed from `anthropic.types.browser_navigate_tool_use_block` (browser_navigate_tool_use_block.py).

import Foundation

public struct BrowserNavigateToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Navigate to a URL, or go back/forward/reload in history.
    ///
    /// The protocol may be omitted (defaults to https://).
    public var input: BrowserNavigateInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserNavigateInput, name: String = "navigate", toolsetName: String = "browser", type: String = "tool_use") {
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
