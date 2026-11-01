// Transformed from `anthropic.types.browser_list_tabs_tool_use_block` (browser_list_tabs_tool_use_block.py).

import Foundation

public struct BrowserListTabsToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// List all open tabs with each tab's tab_id, title, and URL.
    public var input: BrowserListTabsInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserListTabsInput, name: String = "list_tabs", toolsetName: String = "browser", type: String = "tool_use") {
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
