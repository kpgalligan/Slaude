// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_str_replace_command` (beta_memory_tool_20250818_str_replace_command.py).

import Foundation

public struct BetaMemoryTool20250818StrReplaceCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// Text to replace with
    public var newStr: String
    /// Text to search for and replace
    public var oldStr: String
    /// Path to the file where text should be replaced
    public var path: String

    public init(command: String = "str_replace", newStr: String, oldStr: String, path: String) {
        self.command = command
        self.newStr = newStr
        self.oldStr = oldStr
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case command
        case newStr = "new_str"
        case oldStr = "old_str"
        case path
    }
}
