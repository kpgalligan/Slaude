// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_tool_evaluation_always_allow` (beta_managed_agents_agent_tool_evaluation_always_allow.py).

import Foundation

/// The resolved permission_policy was always_allow; accompanies evaluated_permission "allow".
public struct BetaManagedAgentsAgentToolEvaluationAlwaysAllow: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
