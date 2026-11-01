// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_auto_evaluated_permission_ask` (beta_managed_agents_agent_auto_evaluated_permission_ask.py).

import Foundation

/// The server reached no judgement; the invocation is held for client approval.
public struct BetaManagedAgentsAgentAutoEvaluatedPermissionAsk: Codable, Hashable, Sendable {
    /// The judgement's grounds in registry-bound terms, for client branching and audit
    /// rather than end-user display. Open registry; currently "indeterminate" (no
    /// judgement was reached). Clients must tolerate values outside this set.
    public var reasonCode: String
    public var type: String

    public init(reasonCode: String, type: String = "ask") {
        self.reasonCode = reasonCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case reasonCode = "reason_code"
        case type
    }
}
