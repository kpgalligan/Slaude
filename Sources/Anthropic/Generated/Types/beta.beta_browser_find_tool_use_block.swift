// Transformed from `anthropic.types.beta.beta_browser_find_tool_use_block` (beta_browser_find_tool_use_block.py).

import Foundation

public struct BetaBrowserFindToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Find elements matching a natural-language description (e.g.
    ///
    /// "search bar", "add to cart button") and return up to 20 matches with element
    /// references.
    public var input: BetaBrowserFindInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserFindInput, name: String = "find", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
