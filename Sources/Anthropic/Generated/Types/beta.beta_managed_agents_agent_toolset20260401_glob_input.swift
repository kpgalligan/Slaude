// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_glob_input` (beta_managed_agents_agent_toolset20260401_glob_input.py).

import Foundation

/// Input payload for the `glob` tool.
///
/// Returns paths matching a
/// doublestar glob pattern, newest first.
public struct BetaManagedAgentsAgentToolset20260401GlobInput: Codable, Hashable, Sendable {
    /// Doublestar glob pattern (e.g.
    ///
    /// `**/*.go`). Absolute patterns are only permitted when the runner is configured
    /// to allow them.
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
