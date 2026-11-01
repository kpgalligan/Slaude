// Transformed from `anthropic.types.beta.beta_managed_agents_agent_params` (beta_managed_agents_agent_params.py).

import Foundation

/// Specification for an Agent.
///
/// Provide a specific `version` or use the short-form `agent="agent_id"` for the most recent version
public struct BetaManagedAgentsAgentParams: Codable, Hashable, Sendable {
    /// The `agent` ID.
    public var id: String
    public var type: String
    /// The specific `agent` version to use.
    ///
    /// Omit to use the latest version. Must be at least 1 if specified.
    public var version: Int?

    public init(id: String, type: String = "agent", version: Int? = nil) {
        self.id = id
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case version
    }
}
