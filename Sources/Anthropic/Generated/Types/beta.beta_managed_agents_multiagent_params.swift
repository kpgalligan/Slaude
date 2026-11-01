// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_params` (beta_managed_agents_multiagent_params.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentParams: Codable, Hashable, Sendable {
    case coordinator(BetaManagedAgentsMultiagentCoordinatorParams)
    case multiagent20261001(BetaManagedAgentsMultiagent20261001Params)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "coordinator": self = .coordinator(try BetaManagedAgentsMultiagentCoordinatorParams(from: decoder))
        case "multiagent_20261001": self = .multiagent20261001(try BetaManagedAgentsMultiagent20261001Params(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .coordinator(let v): try v.encode(to: encoder)
        case .multiagent20261001(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
