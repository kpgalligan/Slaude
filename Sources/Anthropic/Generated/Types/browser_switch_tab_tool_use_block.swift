// Transformed from `anthropic.types.browser_switch_tab_tool_use_block` (browser_switch_tab_tool_use_block.py).

import Foundation

public struct BrowserSwitchTabToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Make the tab with the given tab_id the active tab — the tab that actions without
    /// a tab_id apply to.
    public var input: BrowserSwitchTabInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserSwitchTabInput, name: String = "switch_tab", toolsetName: String = "browser", type: String = "tool_use") {
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
