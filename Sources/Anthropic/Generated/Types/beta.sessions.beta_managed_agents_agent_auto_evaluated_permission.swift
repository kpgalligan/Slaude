// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_auto_evaluated_permission` (beta_managed_agents_agent_auto_evaluated_permission.py).

import Foundation

public indirect enum BetaManagedAgentsAgentAutoEvaluatedPermission: Codable, Hashable, Sendable {
    case allow(BetaManagedAgentsAgentAutoEvaluatedPermissionAllow)
    case ask(BetaManagedAgentsAgentAutoEvaluatedPermissionAsk)
    case deny(BetaManagedAgentsAgentAutoEvaluatedPermissionDeny)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "allow": self = .allow(try BetaManagedAgentsAgentAutoEvaluatedPermissionAllow(from: decoder))
        case "ask": self = .ask(try BetaManagedAgentsAgentAutoEvaluatedPermissionAsk(from: decoder))
        case "deny": self = .deny(try BetaManagedAgentsAgentAutoEvaluatedPermissionDeny(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .allow(let v): try v.encode(to: encoder)
        case .ask(let v): try v.encode(to: encoder)
        case .deny(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
