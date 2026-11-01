// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_auto_evaluated_permission_allow` (beta_managed_agents_agent_auto_evaluated_permission_allow.py).

import Foundation

/// The server judged the invocation safe to execute without client approval.
public struct BetaManagedAgentsAgentAutoEvaluatedPermissionAllow: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
