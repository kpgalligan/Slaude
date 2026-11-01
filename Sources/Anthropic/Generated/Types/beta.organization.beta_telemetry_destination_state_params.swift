// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_state_params` (beta_telemetry_destination_state_params.py).

import Foundation

public indirect enum BetaTelemetryDestinationStateParams: Codable, Hashable, Sendable {
    case enabled(BetaTelemetryDestinationStateEnabledParams)
    case disabled(BetaTelemetryDestinationStateDisabledParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaTelemetryDestinationStateEnabledParams(from: decoder))
        case "disabled": self = .disabled(try BetaTelemetryDestinationStateDisabledParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .enabled(let v): try v.encode(to: encoder)
        case .disabled(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
