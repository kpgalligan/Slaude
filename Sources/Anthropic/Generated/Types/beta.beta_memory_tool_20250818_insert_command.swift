// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_insert_command` (beta_memory_tool_20250818_insert_command.py).

import Foundation

public struct BetaMemoryTool20250818InsertCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// Line number where text should be inserted
    public var insertLine: Int
    /// Text to insert at the specified line
    public var insertText: String
    /// Path to the file where text should be inserted
    public var path: String

    public init(command: String = "insert", insertLine: Int, insertText: String, path: String) {
        self.command = command
        self.insertLine = insertLine
        self.insertText = insertText
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case command
        case insertLine = "insert_line"
        case insertText = "insert_text"
        case path
    }
}
