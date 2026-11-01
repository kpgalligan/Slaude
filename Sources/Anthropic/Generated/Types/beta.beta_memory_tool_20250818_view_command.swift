// Transformed from `anthropic.types.beta.beta_memory_tool_20250818_view_command` (beta_memory_tool_20250818_view_command.py).

import Foundation

public struct BetaMemoryTool20250818ViewCommand: Codable, Hashable, Sendable {
    /// Command type identifier
    public var command: String
    /// Path to directory or file to view
    public var path: String
    /// Optional line range for viewing specific lines
    public var viewRange: [Int]?

    public init(command: String = "view", path: String, viewRange: [Int]? = nil) {
        self.command = command
        self.path = path
        self.viewRange = viewRange
    }

    enum CodingKeys: String, CodingKey {
        case command
        case path
        case viewRange = "view_range"
    }
}
