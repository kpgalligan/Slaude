// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_create_command` (beta_memory_tool_20250818_create_command.py).

import Foundation

public struct BetaMemoryTool20250818CreateCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// Content to write to the file
    public var fileText: String
    /// Path where the file should be created
    public var path: String

    public init(command: String = "create", fileText: String, path: String) {
        self.command = command
        self.fileText = fileText
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case command
        case fileText = "file_text"
        case path
    }
}
