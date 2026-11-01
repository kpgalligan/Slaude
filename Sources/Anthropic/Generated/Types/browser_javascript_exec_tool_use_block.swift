// Transformed from `anthropic.types.browser_javascript_exec_tool_use_block` (browser_javascript_exec_tool_use_block.py).

import Foundation

public struct BrowserJavascriptExecToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Execute JavaScript in the page context and return the value of the last
    /// expression. The code runs with access to the DOM, `window`, and page variables.
    /// Write the expression you want evaluated — do NOT use `return`.
    public var input: BrowserJavascriptExecInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserJavascriptExecInput, name: String = "javascript_exec", toolsetName: String = "browser", type: String = "tool_use") {
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
