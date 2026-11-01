// Transformed from `anthropic.types.beta.organization.external_key_list_params` (external_key_list_params.py).

import Foundation

public struct BetaOrganizationExternalKeyListParams: Codable, Hashable, Sendable {
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
