// Transformed from `anthropic.types.browser_get_page_text_tool_use_block` (browser_get_page_text_tool_use_block.py).

import Foundation

public struct BrowserGetPageTextToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Return the page's visible text content as plain text, prioritizing article
    /// content. Suited to articles, documentation, and other text-heavy pages.
    public var input: BrowserGetPageTextInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserGetPageTextInput, name: String = "get_page_text", toolsetName: String = "browser", type: String = "tool_use") {
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
