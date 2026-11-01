// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces` (beta_telemetry_destination_workspaces.py).

import Foundation

public indirect enum BetaTelemetryDestinationWorkspaces: Codable, Hashable, Sendable {
    case all(BetaTelemetryDestinationWorkspacesAll)
    case include(BetaTelemetryDestinationWorkspacesInclude)
    case exclude(BetaTelemetryDestinationWorkspacesExclude)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "all": self = .all(try BetaTelemetryDestinationWorkspacesAll(from: decoder))
        case "include": self = .include(try BetaTelemetryDestinationWorkspacesInclude(from: decoder))
        case "exclude": self = .exclude(try BetaTelemetryDestinationWorkspacesExclude(from: decoder))
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
