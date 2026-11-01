// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_state_enabled_params` (beta_telemetry_destination_state_enabled_params.py).

import Foundation

/// Start deliveries to the telemetry destination again.
///
/// This doesn't reset `delivery_health`.
public struct BetaTelemetryDestinationStateEnabledParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
