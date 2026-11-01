// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_state_enabled` (beta_telemetry_destination_state_enabled.py).

import Foundation

/// The telemetry destination receives the spans of the workspaces that it covers.
public struct BetaTelemetryDestinationStateEnabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
