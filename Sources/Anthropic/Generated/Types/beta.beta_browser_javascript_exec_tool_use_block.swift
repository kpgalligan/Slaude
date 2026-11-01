// Transformed from `anthropic.types.beta.beta_browser_javascript_exec_tool_use_block` (beta_browser_javascript_exec_tool_use_block.py).

import Foundation

public struct BetaBrowserJavascriptExecToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Execute JavaScript in the page context and return the value of the last
    /// expression. The code runs with access to the DOM, `window`, and page variables.
    /// Write the expression you want evaluated — do NOT use `return`.
    public var input: BetaBrowserJavascriptExecInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserJavascriptExecInput, name: String = "javascript_exec", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
