// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces_exclude` (beta_telemetry_destination_workspaces_exclude.py).

import Foundation

/// The destination covers every workspace of the organization except the workspaces on its list. A workspace created later is covered until it is added to the list.
public struct BetaTelemetryDestinationWorkspacesExclude: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "exclude") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
