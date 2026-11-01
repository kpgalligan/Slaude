// Transformed from `anthropic.types.organization.federation.rules.workspace_list_params` (workspace_list_params.py).

import Foundation

public struct OrganizationFederationRulesWorkspaceListParams: Codable, Hashable, Sendable {
    /// Number of results per page.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??

    public init(limit: Int? = nil, page: String?? = nil) {
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
    }
}
