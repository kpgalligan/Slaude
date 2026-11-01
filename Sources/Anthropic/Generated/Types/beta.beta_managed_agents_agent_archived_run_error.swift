// Transformed from `anthropic.types.beta.beta_managed_agents_agent_archived_run_error` (beta_managed_agents_agent_archived_run_error.py).

import Foundation

/// The deployment's agent was archived.
public struct BetaManagedAgentsAgentArchivedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "agent_archived_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
