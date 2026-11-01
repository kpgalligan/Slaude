// Transformed from `anthropic.types.beta.beta_browser_close_tab_tool_use_block` (beta_browser_close_tab_tool_use_block.py).

import Foundation

public struct BetaBrowserCloseTabToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Close the tab with the given tab_id.
    public var input: BetaBrowserCloseTabInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserCloseTabInput, name: String = "close_tab", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
