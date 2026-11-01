// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_rename_command` (beta_memory_tool_20250818_rename_command.py).

import Foundation

public struct BetaMemoryTool20250818RenameCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// New path for the file or directory
    public var newPath: String
    /// Current path of the file or directory
    public var oldPath: String

    public init(command: String = "rename", newPath: String, oldPath: String) {
        self.command = command
        self.newPath = newPath
        self.oldPath = oldPath
    }

    enum CodingKeys: String, CodingKey {
        case command
        case newPath = "new_path"
        case oldPath = "old_path"
    }
}
