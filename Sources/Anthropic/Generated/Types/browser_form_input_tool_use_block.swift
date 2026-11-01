// Transformed from `anthropic.types.browser_form_input_tool_use_block` (browser_form_input_tool_use_block.py).

import Foundation

public struct BrowserFormInputToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Set the value of a form element (input, textarea, select, checkbox).
    ///
    /// Use a boolean for checkboxes, an option value or text for selects.
    public var input: BrowserFormInputInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserFormInputInput, name: String = "form_input", toolsetName: String = "browser", type: String = "tool_use") {
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
