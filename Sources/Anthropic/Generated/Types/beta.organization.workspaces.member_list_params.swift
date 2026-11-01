// Transformed from `anthropic.types.beta.organization.workspaces.member_list_params` (member_list_params.py).

import Foundation

public struct BetaOrganizationWorkspacesMemberListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeID: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?

    public init(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.limit = limit
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case limit
    }
}
