// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_predefined_agent_params` (beta_managed_agents_multiagent_predefined_agent_params.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentPredefinedAgentParams: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    case string(String)
    case betaManagedAgentsAgentParams(BetaManagedAgentsAgentParams)
    case betaManagedAgentsMultiagentSelfParams(BetaManagedAgentsMultiagentSelfParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if _Coding.constantsMatch(decoder, ["type": "agent"]), let v = try? BetaManagedAgentsAgentParams(from: decoder) { self = .betaManagedAgentsAgentParams(v); return }
        if _Coding.constantsMatch(decoder, ["type": "self"]), let v = try? BetaManagedAgentsMultiagentSelfParams(from: decoder) { self = .betaManagedAgentsMultiagentSelfParams(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .betaManagedAgentsAgentParams(let v): try v.encode(to: encoder)
        case .betaManagedAgentsMultiagentSelfParams(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
