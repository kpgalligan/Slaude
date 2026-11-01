// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_advisor_params` (beta_managed_agents_multiagent_advisor_params.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentAdvisorParams: Codable, Hashable, Sendable {
    case enabled(BetaManagedAgentsMultiagentAdvisorEnabledParams)
    case disabled(BetaManagedAgentsMultiagentAdvisorDisabledParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaManagedAgentsMultiagentAdvisorEnabledParams(from: decoder))
        case "disabled": self = .disabled(try BetaManagedAgentsMultiagentAdvisorDisabledParams(from: decoder))
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
