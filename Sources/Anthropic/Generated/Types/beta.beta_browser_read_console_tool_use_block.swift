// Transformed from `anthropic.types.beta.beta_browser_read_console_tool_use_block` (beta_browser_read_console_tool_use_block.py).

import Foundation

public struct BetaBrowserReadConsoleToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Return console output (log entries, errors, warnings) accumulated since the
    /// driver attached to the tab and since the last read, one line per entry. An empty
    /// result does not mean no traffic for a tab that predates attach.
    public var input: BetaBrowserReadConsoleInput
    public var name: String
    public var toolsetName: String
    public var type: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: BetaToolUseCaller?

    public init(id: String, input: BetaBrowserReadConsoleInput, name: String = "read_console", toolsetName: String = "browser", type: String = "tool_use", caller: BetaToolUseCaller? = nil) {
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
