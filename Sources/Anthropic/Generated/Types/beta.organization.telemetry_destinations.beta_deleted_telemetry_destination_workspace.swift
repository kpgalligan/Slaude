// Transformed from `anthropic.types.beta.organization.telemetry_destinations.beta_deleted_telemetry_destination_workspace` (beta_deleted_telemetry_destination_workspace.py).

import Foundation

/// Confirmation that a workspace was removed from a destination's list.
public struct BetaDeletedTelemetryDestinationWorkspace: Codable, Hashable, Sendable {
    /// ID of the telemetry destination (`tdst_...`).
    public var telemetryDestinationID: String
    public var type: String
    /// ID of the workspace that was removed (`wrkspc_...`).
    public var workspaceID: String

    public init(telemetryDestinationID: String, type: String = "telemetry_destination_workspace_deleted", workspaceID: String) {
        self.telemetryDestinationID = telemetryDestinationID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case telemetryDestinationID = "telemetry_destination_id"
        case type
        case workspaceID = "workspace_id"
    }
}
