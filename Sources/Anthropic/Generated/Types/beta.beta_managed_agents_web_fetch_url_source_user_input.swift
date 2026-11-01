// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_user_input` (beta_managed_agents_web_fetch_url_source_user_input.py).

import Foundation

public indirect enum BetaManagedAgentsWebFetchURLSourceUserInput: Codable, Hashable, Sendable {
    case all(BetaManagedAgentsWebFetchURLSourceAll)
    case none(BetaManagedAgentsWebFetchURLSourceNone)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "all": self = .all(try BetaManagedAgentsWebFetchURLSourceAll(from: decoder))
        case "none": self = .none(try BetaManagedAgentsWebFetchURLSourceNone(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .all(let v): try v.encode(to: encoder)
        case .none(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
