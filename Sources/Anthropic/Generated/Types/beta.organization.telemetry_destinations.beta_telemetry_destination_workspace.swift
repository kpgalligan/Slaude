// Transformed from `anthropic.types.beta.organization.telemetry_destinations.beta_telemetry_destination_workspace` (beta_telemetry_destination_workspace.py).

import Foundation

/// A workspace on a telemetry destination's workspace list.
///
/// Under `include`, the destination covers the workspace. Under `exclude`, the destination covers every workspace except this one. The entry doesn't have an `id`. Its `telemetry_destination_id` and `workspace_id` together identify it.
public struct BetaTelemetryDestinationWorkspace: Codable, Hashable, Sendable {
    /// Time the workspace was added to the list.
    public var createdAt: Date
    /// ID of the telemetry destination (`tdst_...`).
    public var telemetryDestinationId: String
    public var type: String
    /// ID of the workspace (`wrkspc_...`).
    public var workspaceId: String

    public init(createdAt: Date, telemetryDestinationId: String, type: String = "telemetry_destination_workspace", workspaceId: String) {
        self.createdAt = createdAt
        self.telemetryDestinationId = telemetryDestinationId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case telemetryDestinationId = "telemetry_destination_id"
        case type
        case workspaceId = "workspace_id"
    }
}
