// Transformed from `anthropic.types.beta.beta_browser_read_page_tool_use_block` (beta_browser_read_page_tool_use_block.py).

import Foundation

public struct BetaBrowserReadPageToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Return a structured accessibility tree of the page (or the subtree rooted at
    /// `ref`), with element references like [ref_7] that can be used as targets on
    /// later actions. Output is capped at 50,000 characters — narrow with `ref` or a
    /// smaller `depth` when exceeded.
    public var input: BetaBrowserReadPageInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserReadPageInput, name: String = "read_page", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
