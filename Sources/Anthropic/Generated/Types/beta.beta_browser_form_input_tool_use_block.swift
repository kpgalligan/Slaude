// Transformed from `anthropic.types.beta.beta_browser_form_input_tool_use_block` (beta_browser_form_input_tool_use_block.py).

import Foundation

public struct BetaBrowserFormInputToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Set the value of a form element (input, textarea, select, checkbox).
    ///
    /// Use a boolean for checkboxes, an option value or text for selects.
    public var input: BetaBrowserFormInputInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserFormInputInput, name: String = "form_input", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
