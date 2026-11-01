// Transformed from `anthropic.types.beta.beta_managed_agents_trigger_context` (beta_managed_agents_trigger_context.py).

import Foundation

public indirect enum BetaManagedAgentsTriggerContext: Codable, Hashable, Sendable {
    case schedule(BetaManagedAgentsScheduleTriggerContext)
    case manual(BetaManagedAgentsManualTriggerContext)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "schedule": self = .schedule(try BetaManagedAgentsScheduleTriggerContext(from: decoder))
        case "manual": self = .manual(try BetaManagedAgentsManualTriggerContext(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .schedule(let v): try v.encode(to: encoder)
        case .manual(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
