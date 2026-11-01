// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_user_input_param` (beta_managed_agents_web_fetch_url_source_user_input_param.py).

import Foundation

public indirect enum BetaManagedAgentsWebFetchURLSourceUserInputParam: Codable, Hashable, Sendable {
    case all(BetaManagedAgentsWebFetchURLSourceAllParam)
    case none(BetaManagedAgentsWebFetchURLSourceNoneParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "all": self = .all(try BetaManagedAgentsWebFetchURLSourceAllParam(from: decoder))
        case "none": self = .none(try BetaManagedAgentsWebFetchURLSourceNoneParam(from: decoder))
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
