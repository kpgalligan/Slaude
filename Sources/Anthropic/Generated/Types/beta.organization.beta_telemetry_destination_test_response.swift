// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_test_response` (beta_telemetry_destination_test_response.py).

import Foundation

/// The result of one test span sent to a destination.
public struct BetaTelemetryDestinationTestResponse: Codable, Hashable, Sendable {
    /// How the test went: `success` when the destination answered with a 2xx status,
    /// else `failure` with the reason.
    public var result: BetaTelemetryDestinationTestResult
    public var type: String

    public init(result: BetaTelemetryDestinationTestResult, type: String = "telemetry_destination_test") {
        self.result = result
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case result
        case type
    }
}
