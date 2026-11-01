// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_grep_input` (beta_managed_agents_agent_toolset20260401_grep_input.py).

import Foundation

/// Input payload for the `grep` tool.
///
/// Searches file contents for
/// a regular expression, returning matching lines.
public struct BetaManagedAgentsAgentToolset20260401GrepInput: Codable, Hashable, Sendable {
    /// Regular expression to search for.
    public var pattern: String
    /// Optional directory root to search under.
    ///
    /// Defaults to the runner's working directory.
    public var path: String?

    public init(pattern: String, path: String? = nil) {
        self.pattern = pattern
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case pattern
        case path
    }
}
