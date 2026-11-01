// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_state_disabled` (beta_telemetry_destination_state_disabled.py).

import Foundation

/// The API doesn't deliver anything to the telemetry destination.
///
/// Spans produced while it is disabled aren't delivered later.
public struct BetaTelemetryDestinationStateDisabled: Codable, Hashable, Sendable {
    /// Whether a caller or the API disabled the destination and, when the API did, why.
    ///
    /// Read-only.
    public var reason: BetaTelemetryDestinationDisabledReason
    public var type: String

    public init(reason: BetaTelemetryDestinationDisabledReason, type: String = "disabled") {
        self.reason = reason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case reason
        case type
    }
}
