// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_egress_blocked_deployment_paused_reason_error` (beta_managed_agents_mcp_egress_blocked_deployment_paused_reason_error.py).

import Foundation

/// An MCP server host used by the deployment's agent is blocked by the environment's network policy.
public struct BetaManagedAgentsMCPEgressBlockedDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "mcp_egress_blocked_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
