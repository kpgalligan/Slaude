// Transformed from `anthropic.types.beta.beta_browser_list_tabs_tool_use_block` (beta_browser_list_tabs_tool_use_block.py).

import Foundation

public struct BetaBrowserListTabsToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// List all open tabs with each tab's tab_id, title, and URL.
    public var input: BetaBrowserListTabsInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserListTabsInput, name: String = "list_tabs", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
