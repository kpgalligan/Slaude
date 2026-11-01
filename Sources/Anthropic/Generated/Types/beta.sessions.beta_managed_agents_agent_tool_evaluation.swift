// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_tool_evaluation` (beta_managed_agents_agent_tool_evaluation.py).

import Foundation

public indirect enum BetaManagedAgentsAgentToolEvaluation: Codable, Hashable, Sendable {
    case alwaysAllow(BetaManagedAgentsAgentToolEvaluationAlwaysAllow)
    case alwaysAsk(BetaManagedAgentsAgentToolEvaluationAlwaysAsk)
    case auto(BetaManagedAgentsAgentToolEvaluationAuto)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "always_allow": self = .alwaysAllow(try BetaManagedAgentsAgentToolEvaluationAlwaysAllow(from: decoder))
        case "always_ask": self = .alwaysAsk(try BetaManagedAgentsAgentToolEvaluationAlwaysAsk(from: decoder))
        case "auto": self = .auto(try BetaManagedAgentsAgentToolEvaluationAuto(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .alwaysAllow(let v): try v.encode(to: encoder)
        case .alwaysAsk(let v): try v.encode(to: encoder)
        case .auto(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
