// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_evaluated_permission` (beta_managed_agents_agent_evaluated_permission.py).

import Foundation

public enum BetaManagedAgentsAgentEvaluatedPermission: OpenEnum, CaseIterable {
    case allow
    case ask
    case deny
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsAgentEvaluatedPermission] = [.allow, .ask, .deny]

    public init(rawValue: String) {
        switch rawValue {
        case "allow": self = .allow
        case "ask": self = .ask
        case "deny": self = .deny
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .allow: return "allow"
        case .ask: return "ask"
        case .deny: return "deny"
        case .unknown(let value): return value
        }
    }
}
