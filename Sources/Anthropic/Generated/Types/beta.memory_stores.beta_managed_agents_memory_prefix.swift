// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory_prefix` (beta_managed_agents_memory_prefix.py).

import Foundation

/// A directory marker that [List Memories](https://platform.claude.com/docs/en/api/beta/memory_stores/memories/list) returns instead of the memories below the requested `depth`.
///
/// It stands for one or more memories whose paths start with `path`. It isn't a stored object and doesn't have an ID. Each marker counts toward the page `limit`.
public struct BetaManagedAgentsMemoryPrefix: Codable, Hashable, Sendable {
    /// The rolled-up path prefix, including a trailing `/` (e.g.
    ///
    /// `/projects/foo/`). Pass this value as `path_prefix` on a subsequent list call to
    /// drill into the directory.
    public var path: String
    public var type: String

    public init(path: String, type: String = "memory_prefix") {
        self.path = path
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case path
        case type
    }
}
