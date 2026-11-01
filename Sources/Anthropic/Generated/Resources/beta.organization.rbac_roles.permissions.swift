// Transformed from `anthropic.resources.beta.organization.rbac_roles.permissions` (permissions.py).

import Foundation

public struct BetaOrganizationRbacRolesPermissionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List the permissions an RBAC Role grants.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ rbacRoleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaRBACRolePermission> {
        try await _list(rbacRoleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ rbacRoleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaRBACRolePermission>> {
        try requireNonEmpty(rbacRoleID, "rbac_role_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/rbac_roles/{rbac_role_id}/permissions", ["rbac_role_id": rbacRoleID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_roles.permissions.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaRBACRolePermission>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationRbacRolesPermissionsResource

    /// List the permissions an RBAC Role grants.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ rbacRoleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaRBACRolePermission>> {
            try await resource._list(rbacRoleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationRbacRolesPermissionsResource

    /// List the permissions an RBAC Role grants.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ rbacRoleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaRBACRolePermission>>) async throws -> R) async throws -> R {
            let response = try await resource._list(rbacRoleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
