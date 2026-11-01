// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_auto_evaluated_permission_deny` (beta_managed_agents_agent_auto_evaluated_permission_deny.py).

import Foundation

/// The server judged the invocation high-risk; it does not execute and a synthetic error tool result is appended.
public struct BetaManagedAgentsAgentAutoEvaluatedPermissionDeny: Codable, Hashable, Sendable {
    /// The judgement's grounds in registry-bound terms.
    ///
    /// Open registry; currently "high_risk" (judged high-risk; the call does not run).
    /// Clients must tolerate values outside this set.
    public var reasonCode: String
    public var type: String

    public init(reasonCode: String, type: String = "deny") {
        self.reasonCode = reasonCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case reasonCode = "reason_code"
        case type
    }
}
