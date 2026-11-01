// Transformed from `anthropic.types.browser_find_tool_use_block` (browser_find_tool_use_block.py).

import Foundation

public struct BrowserFindToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Find elements matching a natural-language description (e.g.
    ///
    /// "search bar", "add to cart button") and return up to 20 matches with element
    /// references.
    public var input: BrowserFindInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserFindInput, name: String = "find", toolsetName: String = "browser", type: String = "tool_use") {
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
