// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_workspaces_all_params` (beta_telemetry_destination_workspaces_all_params.py).

import Foundation

/// Cover every workspace of the organization. Doesn't take `workspace_ids`.
///
/// An update that sets `all` empties the destination's workspace list.
public struct BetaTelemetryDestinationWorkspacesAllParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
