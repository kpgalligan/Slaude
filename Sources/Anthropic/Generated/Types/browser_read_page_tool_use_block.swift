// Transformed from `anthropic.types.browser_read_page_tool_use_block` (browser_read_page_tool_use_block.py).

import Foundation

public struct BrowserReadPageToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Return a structured accessibility tree of the page (or the subtree rooted at
    /// `ref`), with element references like [ref_7] that can be used as targets on
    /// later actions. Output is capped at 50,000 characters — narrow with `ref` or a
    /// smaller `depth` when exceeded.
    public var input: BrowserReadPageInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserReadPageInput, name: String = "read_page", toolsetName: String = "browser", type: String = "tool_use") {
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
