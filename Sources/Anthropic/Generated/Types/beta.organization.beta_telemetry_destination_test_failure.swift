// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_test_failure` (beta_telemetry_destination_test_failure.py).

import Foundation

/// The test span was not delivered.
public struct BetaTelemetryDestinationTestFailure: Codable, Hashable, Sendable {
    /// A message that describes why the test span was not delivered, including the HTTP
    /// status code when the destination returned one. Examples:
    /// `HTTP error (status 403)`, `timeout`, `TLS failure`. It has the same form as the
    /// destination's `delivery_health.last_error` and never contains the destination's
    /// response body, any header value, a network address, or TLS details.
    public var error: String
    public var type: String

    public init(error: String, type: String = "failure") {
        self.error = error
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case type
    }
}
