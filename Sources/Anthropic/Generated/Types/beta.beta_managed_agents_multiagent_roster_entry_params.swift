// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_roster_entry_params` (beta_managed_agents_multiagent_roster_entry_params.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentRosterEntryParams: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    case string(String)
    case betaManagedAgentsAgentParams(BetaManagedAgentsAgentParams)
    case betaManagedAgentsMultiagentSelfParams(BetaManagedAgentsMultiagentSelfParams)
    case betaManagedAgentsAdvisorParams(BetaManagedAgentsAdvisorParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if _Coding.constantsMatch(decoder, ["type": "agent"]), let v = try? BetaManagedAgentsAgentParams(from: decoder) { self = .betaManagedAgentsAgentParams(v); return }
        if _Coding.constantsMatch(decoder, ["type": "self"]), let v = try? BetaManagedAgentsMultiagentSelfParams(from: decoder) { self = .betaManagedAgentsMultiagentSelfParams(v); return }
        if _Coding.constantsMatch(decoder, ["type": "advisor"]), let v = try? BetaManagedAgentsAdvisorParams(from: decoder) { self = .betaManagedAgentsAdvisorParams(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .betaManagedAgentsAgentParams(let v): try v.encode(to: encoder)
        case .betaManagedAgentsMultiagentSelfParams(let v): try v.encode(to: encoder)
        case .betaManagedAgentsAdvisorParams(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
