// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_test_success` (beta_telemetry_destination_test_success.py).

import Foundation

/// The destination answered the test span with a 2xx status.
public struct BetaTelemetryDestinationTestSuccess: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "success") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
