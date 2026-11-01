// Transformed from `anthropic.types.beta.organization.telemetry_destination_list_params` (telemetry_destination_list_params.py).

import Foundation

public struct TelemetryDestinationListParams: Codable, Hashable, Sendable {
    /// Number of destinations to return per page, between 1 and 1,000. Defaults to 20.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    ///
    /// Leave it out to get the first page.
    public var page: String?
    /// Return only the destinations that cover at least one of these workspaces
    /// (`wrkspc_...`).
    ///
    /// Send at most 100 IDs, as `workspace_ids[]`. A destination covers a workspace
    /// when its `workspaces.type` is `all`, when its `include` list has the workspace,
    /// or when its `exclude` list doesn't have it. Destinations in either state can
    /// match. An ID that isn't the ID of one of the organization's workspaces doesn't
    /// match any destination, not even one whose type is `all`.
    public var workspaceIDs: [String]?
    /// This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    /// in this header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String? = nil, workspaceIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.page = page
        self.workspaceIDs = workspaceIDs
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case workspaceIDs = "workspace_ids"
        case betas
    }
}
