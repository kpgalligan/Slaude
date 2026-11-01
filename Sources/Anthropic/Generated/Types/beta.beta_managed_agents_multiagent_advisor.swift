// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_advisor` (beta_managed_agents_multiagent_advisor.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentAdvisor: Codable, Hashable, Sendable {
    case enabled(BetaManagedAgentsMultiagentAdvisorEnabled)
    case disabled(BetaManagedAgentsMultiagentAdvisorDisabled)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaManagedAgentsMultiagentAdvisorEnabled(from: decoder))
        case "disabled": self = .disabled(try BetaManagedAgentsMultiagentAdvisorDisabled(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .enabled(let v): try v.encode(to: encoder)
        case .disabled(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
