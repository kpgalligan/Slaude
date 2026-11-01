// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_test_result` (beta_telemetry_destination_test_result.py).

import Foundation

public indirect enum BetaTelemetryDestinationTestResult: Codable, Hashable, Sendable {
    case success(BetaTelemetryDestinationTestSuccess)
    case failure(BetaTelemetryDestinationTestFailure)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "success": self = .success(try BetaTelemetryDestinationTestSuccess(from: decoder))
        case "failure": self = .failure(try BetaTelemetryDestinationTestFailure(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .success(let v): try v.encode(to: encoder)
        case .failure(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
