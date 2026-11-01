// Transformed from `anthropic.types.beta.organization.workspaces.member_list_params` (member_list_params.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterId: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeId: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?

    public init(afterId: String? = nil, beforeId: String? = nil, limit: Int? = nil) {
        self.afterId = afterId
        self.beforeId = beforeId
        self.limit = limit
    }

    enum CodingKeys: String, CodingKey {
        case afterId = "after_id"
        case beforeId = "before_id"
        case limit
    }
}
