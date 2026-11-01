// Transformed from `anthropic.types.beta.organization.rbac_groups.member_list_params` (member_list_params.py).

import Foundation

public struct BetaOrganizationRbacGroupsMemberListParams: Codable, Hashable, Sendable {
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Optionally set to the `next_page` token from the previous response.
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
