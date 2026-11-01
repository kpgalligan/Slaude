// Transformed from `anthropic.types.beta.organization.beta_deleted_telemetry_destination` (beta_deleted_telemetry_destination.py).

import Foundation

/// Confirmation that a destination was deleted.
public struct BetaDeletedTelemetryDestination: Codable, Hashable, Sendable {
    /// ID of the deleted destination (`tdst_...`).
    public var id: String
    public var type: String

    public init(id: String, type: String = "telemetry_destination_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
