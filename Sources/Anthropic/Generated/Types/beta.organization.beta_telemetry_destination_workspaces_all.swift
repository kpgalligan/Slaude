// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces_all` (beta_telemetry_destination_workspaces_all.py).

import Foundation

/// The destination covers every workspace of the organization, including the default workspace, archived workspaces, and workspaces created later. It doesn't have a list.
public struct BetaTelemetryDestinationWorkspacesAll: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
