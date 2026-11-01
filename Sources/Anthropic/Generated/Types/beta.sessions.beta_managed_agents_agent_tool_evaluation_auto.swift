// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_tool_evaluation_auto` (beta_managed_agents_agent_tool_evaluation_auto.py).

import Foundation

/// The resolved permission_policy was auto: the server judged this invocation individually.
public struct BetaManagedAgentsAgentToolEvaluationAuto: Codable, Hashable, Sendable {
    /// The server's judgement for this invocation.
    public var evaluatedPermission: BetaManagedAgentsAgentAutoEvaluatedPermission
    public var type: String

    public init(evaluatedPermission: BetaManagedAgentsAgentAutoEvaluatedPermission, type: String = "auto") {
        self.evaluatedPermission = evaluatedPermission
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case evaluatedPermission = "evaluated_permission"
        case type
    }
}
