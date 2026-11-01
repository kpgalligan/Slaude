// Transformed from `anthropic.types.beta.beta_managed_agents_skill_params` (beta_managed_agents_skill_params.py).

import Foundation

public indirect enum BetaManagedAgentsSkillParams: Codable, Hashable, Sendable {
    case anthropic(BetaManagedAgentsAnthropicSkillParams)
    case custom(BetaManagedAgentsCustomSkillParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "anthropic": self = .anthropic(try BetaManagedAgentsAnthropicSkillParams(from: decoder))
        case "custom": self = .custom(try BetaManagedAgentsCustomSkillParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .anthropic(let v): try v.encode(to: encoder)
        case .custom(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
