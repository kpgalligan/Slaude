// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_actor` (beta_managed_agents_actor.py).

import Foundation

public indirect enum BetaManagedAgentsActor: Codable, Hashable, Sendable {
    case sessionActor(BetaManagedAgentsSessionActor)
    case apiActor(BetaManagedAgentsAPIActor)
    case userActor(BetaManagedAgentsUserActor)
    case serviceAccountActor(BetaManagedAgentsServiceAccountActor)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "session_actor": self = .sessionActor(try BetaManagedAgentsSessionActor(from: decoder))
        case "api_actor": self = .apiActor(try BetaManagedAgentsAPIActor(from: decoder))
        case "user_actor": self = .userActor(try BetaManagedAgentsUserActor(from: decoder))
        case "service_account_actor": self = .serviceAccountActor(try BetaManagedAgentsServiceAccountActor(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .sessionActor(let v): try v.encode(to: encoder)
        case .apiActor(let v): try v.encode(to: encoder)
        case .userActor(let v): try v.encode(to: encoder)
        case .serviceAccountActor(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
