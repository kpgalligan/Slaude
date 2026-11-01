// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_egress_blocked_run_error` (beta_managed_agents_mcp_egress_blocked_run_error.py).

import Foundation

/// An MCP server host used by the deployment's agent is blocked by the environment's network policy.
public struct BetaManagedAgentsMCPEgressBlockedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "mcp_egress_blocked_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
