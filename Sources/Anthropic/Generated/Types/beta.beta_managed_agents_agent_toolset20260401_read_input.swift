// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_read_input` (beta_managed_agents_agent_toolset20260401_read_input.py).

import Foundation

/// Input payload for the `read` tool.
///
/// Reads file contents
/// relative to the runner's working directory (or absolute when
/// the runner permits).
public struct BetaManagedAgentsAgentToolset20260401ReadInput: Codable, Hashable, Sendable {
    /// Path of the file to read.
    public var filePath: String
    /// Optional `[start_line, end_line]` 1-indexed inclusive range.
    ///
    /// When omitted the entire file is returned. `end_line` of 0 or negative means "to
    /// end of file".
    public var viewRange: [Int]?

    public init(filePath: String, viewRange: [Int]? = nil) {
        self.filePath = filePath
        self.viewRange = viewRange
    }

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case viewRange = "view_range"
    }
}
