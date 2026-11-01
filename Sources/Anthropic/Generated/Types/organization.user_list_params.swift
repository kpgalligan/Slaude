// Transformed from `anthropic.types.organization.user_list_params` (user_list_params.py).

import Foundation

public struct UserListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterId: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeId: String?
    /// Filter by user email.
    public var email: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Filter to items whose `role` equals one of the supplied values.
    ///
    /// Repeatable; values are OR'ed together.
    ///
    /// Accepted values depend on the organization type: Console and API organizations
    /// accept `user`, `developer`, `billing`, `admin`, and `claude_code_user`; Claude
    /// Enterprise organizations accept `user`, `owner`, `primary_owner`,
    /// `membership_admin`, and `managed`.
    public var roles: [String]?

    public init(afterId: String? = nil, beforeId: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil) {
        self.afterId = afterId
        self.beforeId = beforeId
        self.email = email
        self.limit = limit
        self.roles = roles
    }

    enum CodingKeys: String, CodingKey {
        case afterId = "after_id"
        case beforeId = "before_id"
        case email
        case limit
        case roles
    }
}
