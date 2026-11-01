// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_tool_evaluation_always_ask` (beta_managed_agents_agent_tool_evaluation_always_ask.py).

import Foundation

/// The resolved permission_policy was always_ask; accompanies evaluated_permission "ask".
public struct BetaManagedAgentsAgentToolEvaluationAlwaysAsk: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "always_ask") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
