// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_tool_filter` (beta_managed_agents_web_fetch_url_source_tool_filter.py).

import Foundation

public indirect enum BetaManagedAgentsWebFetchURLSourceToolFilter: Codable, Hashable, Sendable {
    case all(BetaManagedAgentsWebFetchURLSourceAll)
    case none(BetaManagedAgentsWebFetchURLSourceNone)
    case only(BetaManagedAgentsWebFetchURLSourceOnly)
    case except(BetaManagedAgentsWebFetchURLSourceExcept)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "all": self = .all(try BetaManagedAgentsWebFetchURLSourceAll(from: decoder))
        case "none": self = .none(try BetaManagedAgentsWebFetchURLSourceNone(from: decoder))
        case "only": self = .only(try BetaManagedAgentsWebFetchURLSourceOnly(from: decoder))
        case "except": self = .except(try BetaManagedAgentsWebFetchURLSourceExcept(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .all(let v): try v.encode(to: encoder)
        case .none(let v): try v.encode(to: encoder)
        case .only(let v): try v.encode(to: encoder)
        case .except(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
