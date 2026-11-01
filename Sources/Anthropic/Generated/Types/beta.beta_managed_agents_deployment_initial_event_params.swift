// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_initial_event_params` (beta_managed_agents_deployment_initial_event_params.py).

import Foundation

public indirect enum BetaManagedAgentsDeploymentInitialEventParams: Codable, Hashable, Sendable {
    case userMessage(BetaManagedAgentsUserMessageEventParams)
    case userDefineOutcome(BetaManagedAgentsUserDefineOutcomeEventParams)
    case systemMessage(BetaManagedAgentsSystemMessageEventParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "user.message": self = .userMessage(try BetaManagedAgentsUserMessageEventParams(from: decoder))
        case "user.define_outcome": self = .userDefineOutcome(try BetaManagedAgentsUserDefineOutcomeEventParams(from: decoder))
        case "system.message": self = .systemMessage(try BetaManagedAgentsSystemMessageEventParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .userMessage(let v): try v.encode(to: encoder)
        case .userDefineOutcome(let v): try v.encode(to: encoder)
        case .systemMessage(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
