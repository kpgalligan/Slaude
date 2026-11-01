// Transformed from `anthropic.types.beta.beta_browser_navigate_tool_use_block` (beta_browser_navigate_tool_use_block.py).

import Foundation

public struct BetaBrowserNavigateToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Navigate to a URL, or go back/forward/reload in history.
    ///
    /// The protocol may be omitted (defaults to https://).
    public var input: BetaBrowserNavigateInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserNavigateInput, name: String = "navigate", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
