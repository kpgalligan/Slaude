// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_initial_event` (beta_managed_agents_deployment_initial_event.py).

import Foundation

public indirect enum BetaManagedAgentsDeploymentInitialEvent: Codable, Hashable, Sendable {
    case userMessage(BetaManagedAgentsDeploymentUserMessageEvent)
    case userDefineOutcome(BetaManagedAgentsDeploymentUserDefineOutcomeEvent)
    case systemMessage(BetaManagedAgentsDeploymentSystemMessageEvent)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "user.message": self = .userMessage(try BetaManagedAgentsDeploymentUserMessageEvent(from: decoder))
        case "user.define_outcome": self = .userDefineOutcome(try BetaManagedAgentsDeploymentUserDefineOutcomeEvent(from: decoder))
        case "system.message": self = .systemMessage(try BetaManagedAgentsDeploymentSystemMessageEvent(from: decoder))
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
