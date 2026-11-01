// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_state_disabled_params` (beta_telemetry_destination_state_disabled_params.py).

import Foundation

/// Stop deliveries to the telemetry destination.
///
/// Spans produced while it is disabled aren't delivered later. A destination that is already disabled keeps its `reason`.
public struct BetaTelemetryDestinationStateDisabledParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
