// Transformed from `anthropic.types.beta.beta_computer_screenshot_tool_use_block` (beta_computer_screenshot_tool_use_block.py).

import Foundation

public struct BetaComputerScreenshotToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Take a screenshot of the screen.
    public var input: BetaComputerScreenshotInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaComputerScreenshotInput, name: String = "screenshot", toolsetName: String = "computer", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
