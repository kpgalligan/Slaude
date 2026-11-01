// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_delete_command` (beta_memory_tool_20250818_delete_command.py).

import Foundation

public struct BetaMemoryTool20250818DeleteCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// Path to the file or directory to delete
    public var path: String

    public init(command: String = "delete", path: String) {
        self.command = command
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case command
        case path
    }
}
