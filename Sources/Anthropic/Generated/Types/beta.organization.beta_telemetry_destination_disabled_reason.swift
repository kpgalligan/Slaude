// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_disabled_reason` (beta_telemetry_destination_disabled_reason.py).

import Foundation

public indirect enum BetaTelemetryDestinationDisabledReason: Codable, Hashable, Sendable {
    case caller(BetaTelemetryDestinationDisabledReasonCaller)
    case sustainedFailure(BetaTelemetryDestinationDisabledReasonSustainedFailure)
    case invalidAddress(BetaTelemetryDestinationDisabledReasonInvalidAddress)
    case redirect(BetaTelemetryDestinationDisabledReasonRedirect)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "caller": self = .caller(try BetaTelemetryDestinationDisabledReasonCaller(from: decoder))
        case "sustained_failure": self = .sustainedFailure(try BetaTelemetryDestinationDisabledReasonSustainedFailure(from: decoder))
        case "invalid_address": self = .invalidAddress(try BetaTelemetryDestinationDisabledReasonInvalidAddress(from: decoder))
        case "redirect": self = .redirect(try BetaTelemetryDestinationDisabledReasonRedirect(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .caller(let v): try v.encode(to: encoder)
        case .sustainedFailure(let v): try v.encode(to: encoder)
        case .invalidAddress(let v): try v.encode(to: encoder)
        case .redirect(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
