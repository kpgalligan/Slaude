// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_user_input_params` (beta_managed_agents_web_fetch_url_source_user_input_params.py).

import Foundation

public indirect enum BetaManagedAgentsWebFetchURLSourceUserInputParams: Codable, Hashable, Sendable {
    case betaManagedAgentsWebFetchURLSourceShorthand(BetaManagedAgentsWebFetchURLSourceShorthand)
    case betaManagedAgentsWebFetchURLSourceUserInputParam(BetaManagedAgentsWebFetchURLSourceUserInputParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaManagedAgentsWebFetchURLSourceShorthand(from: decoder) { self = .betaManagedAgentsWebFetchURLSourceShorthand(v); return }
        if let v = try? BetaManagedAgentsWebFetchURLSourceUserInputParam(from: decoder) { self = .betaManagedAgentsWebFetchURLSourceUserInputParam(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaManagedAgentsWebFetchURLSourceShorthand(let v): try v.encode(to: encoder)
        case .betaManagedAgentsWebFetchURLSourceUserInputParam(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
