// Transformed from `anthropic.types.organization.federation.issuer_list_params` (issuer_list_params.py).

import Foundation

public struct IssuerListParams: Codable, Hashable, Sendable {
    /// Include archived resources. Defaults to false.
    public var includeArchived: Bool?
    /// Number of results per page.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??

    public init(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil) {
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case includeArchived = "include_archived"
        case limit
        case page
    }
}
