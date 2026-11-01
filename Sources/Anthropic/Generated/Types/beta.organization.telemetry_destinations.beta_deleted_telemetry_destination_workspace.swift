// Transformed from `anthropic.types.beta.organization.telemetry_destinations.beta_deleted_telemetry_destination_workspace` (beta_deleted_telemetry_destination_workspace.py).

import Foundation

/// Confirmation that a workspace was removed from a destination's list.
public struct BetaDeletedTelemetryDestinationWorkspace: Codable, Hashable, Sendable {
    /// ID of the telemetry destination (`tdst_...`).
    public var telemetryDestinationId: String
    public var type: String
    /// ID of the workspace that was removed (`wrkspc_...`).
    public var workspaceId: String

    public init(telemetryDestinationId: String, type: String = "telemetry_destination_workspace_deleted", workspaceId: String) {
        self.telemetryDestinationId = telemetryDestinationId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case telemetryDestinationId = "telemetry_destination_id"
        case type
        case workspaceId = "workspace_id"
    }
}
