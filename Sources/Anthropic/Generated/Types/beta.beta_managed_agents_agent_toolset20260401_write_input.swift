// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_write_input` (beta_managed_agents_agent_toolset20260401_write_input.py).

import Foundation

/// Input payload for the `write` tool.
///
/// Writes (overwriting) the
/// entire file contents.
public struct BetaManagedAgentsAgentToolset20260401WriteInput: Codable, Hashable, Sendable {
    /// Full file contents to write.
    public var content: String
    /// Path of the file to write.
    public var filePath: String

    public init(content: String, filePath: String) {
        self.content = content
        self.filePath = filePath
    }

    enum CodingKeys: String, CodingKey {
        case content
        case filePath = "file_path"
    }
}
