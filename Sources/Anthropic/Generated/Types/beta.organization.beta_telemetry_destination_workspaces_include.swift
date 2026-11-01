// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces_include` (beta_telemetry_destination_workspaces_include.py).

import Foundation

/// The destination covers the workspaces on its list, and no others.
public struct BetaTelemetryDestinationWorkspacesInclude: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "include") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
