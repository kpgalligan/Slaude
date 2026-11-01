// Transformed from `anthropic.types.beta.beta_browser_middle_click_tool_use_block` (beta_browser_middle_click_tool_use_block.py).

import Foundation

public struct BetaBrowserMiddleClickToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Middle-click at a viewport coordinate or on an element by reference.
    public var input: BetaBrowserMiddleClickInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserMiddleClickInput, name: String = "middle_click", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
