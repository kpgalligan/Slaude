// Transformed from `anthropic.types.browser_read_console_tool_use_block` (browser_read_console_tool_use_block.py).

import Foundation

public struct BrowserReadConsoleToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Return console output (log entries, errors, warnings) accumulated since the
    /// driver attached to the tab and since the last read, one line per entry. An empty
    /// result does not mean no traffic for a tab that predates attach.
    public var input: BrowserReadConsoleInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserReadConsoleInput, name: String = "read_console", toolsetName: String = "browser", type: String = "tool_use") {
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
