// Transformed from `anthropic.types.user_profile_list_params` (user_profile_list_params.py).

import Foundation

public struct UserProfileListParams: Codable, Hashable, Sendable {
    /// Return only the user profiles whose `enforcement_status` is one of these values:
    /// `unrestricted`, `pending`, `restricted` or `banned`. Repeat the parameter to
    /// match any of several. With it set, a page may hold fewer than `limit` profiles,
    /// or none, and still carry a `next_page`: the service examines a bounded number of
    /// profiles per request, and only a null `next_page` means the listing is complete.
    /// Rejected with `invalid_request_error` under the `user-profiles-2026-09-04` and
    /// earlier beta headers. Fails with `overloaded_error` when a profile's enforcement
    /// actions cannot be read for the moment.
    public var enforcementStatus: [UserProfileEnforcementStatus]?
    /// The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    public var limit: Int?
    /// The sort direction, applied to the field that `order_by` selects.
    ///
    /// Defaults to `desc`.
    public var order: UserProfileListOrder?
    /// The field to sort user profiles by, in the direction that `order` sets.
    ///
    /// Defaults to `created_at`.
    public var orderBy: UserProfileListOrderBy?
    /// The cursor for the page to return, taken from `next_page` in a previous
    /// response.
    ///
    /// Leave it out to get the first page.
    public var page: String?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(enforcementStatus: [UserProfileEnforcementStatus]? = nil, limit: Int? = nil, order: UserProfileListOrder? = nil, orderBy: UserProfileListOrderBy? = nil, page: String? = nil, workspaceID: String? = nil) {
        self.enforcementStatus = enforcementStatus
        self.limit = limit
        self.order = order
        self.orderBy = orderBy
        self.page = page
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case enforcementStatus = "enforcement_status"
        case limit
        case order
        case orderBy = "order_by"
        case page
        case workspaceID = "workspace_id"
    }
}
