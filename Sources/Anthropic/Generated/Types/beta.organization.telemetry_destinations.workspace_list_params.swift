// Transformed from `anthropic.types.beta.organization.telemetry_destinations.workspace_list_params` (workspace_list_params.py).

import Foundation

public struct BetaOrganizationTelemetryDestinationsWorkspaceListParams: Codable, Hashable, Sendable {
    /// Number of entries to return per page, between 1 and 1,000. Defaults to 20.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    ///
    /// Leave it out to get the first page.
    public var page: String?
    /// This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    /// in this header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.page = page
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case betas
    }
}
