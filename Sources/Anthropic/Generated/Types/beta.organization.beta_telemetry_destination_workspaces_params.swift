// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces_params` (beta_telemetry_destination_workspaces_params.py).

import Foundation

public indirect enum BetaTelemetryDestinationWorkspacesParams: Codable, Hashable, Sendable {
    case all(BetaTelemetryDestinationWorkspacesAllParams)
    case include(BetaTelemetryDestinationWorkspacesIncludeParams)
    case exclude(BetaTelemetryDestinationWorkspacesExcludeParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "all": self = .all(try BetaTelemetryDestinationWorkspacesAllParams(from: decoder))
        case "include": self = .include(try BetaTelemetryDestinationWorkspacesIncludeParams(from: decoder))
        case "exclude": self = .exclude(try BetaTelemetryDestinationWorkspacesExcludeParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .all(let v): try v.encode(to: encoder)
        case .include(let v): try v.encode(to: encoder)
        case .exclude(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
