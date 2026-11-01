// Transformed from `anthropic.resources.beta.organization.rbac_roles.rbac_roles` (rbac_roles.py).

import Foundation

public struct BetaOrganizationRbacRolesRBACRolesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var permissions: BetaOrganizationRbacRolesPermissionsResource { BetaOrganizationRbacRolesPermissionsResource(client: client) }

    /// Retrieve an RBAC Role by ID.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ rbacRoleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaRBACRole {
        try await _retrieve(rbacRoleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ rbacRoleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaRBACRole> {
        try requireNonEmpty(rbacRoleID, "rbac_role_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/rbac_roles/{rbac_role_id}", ["rbac_role_id": rbacRoleID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_roles.retrieve")
        return try await client.requestResponse(BetaRBACRole.self, options, stream: _mode == .stream)
    }

    /// List RBAC Roles in the organization.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
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
    public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaRBACRole> {
        try await _list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaRBACRole>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/rbac_roles", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_roles.list")
        return try await client.requestPageResponse(PageCursor<BetaRBACRole>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationRbacRolesRBACRolesResource

        public var permissions: BetaOrganizationRbacRolesPermissionsResource.WithRawResponse { resource.permissions.withRawResponse }

    /// Retrieve an RBAC Role by ID.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ rbacRoleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaRBACRole> {
            try await resource._retrieve(rbacRoleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List RBAC Roles in the organization.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
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
        public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaRBACRole>> {
            try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationRbacRolesRBACRolesResource

        public var permissions: BetaOrganizationRbacRolesPermissionsResource.WithStreamingResponse { resource.permissions.withStreamingResponse }

    /// Retrieve an RBAC Role by ID.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_role_id: ID of the RBAC Role.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ rbacRoleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaRBACRole>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(rbacRoleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List RBAC Roles in the organization.
    ///
    /// The RBAC Roles API is available to Claude Enterprise organizations only.
    ///
    /// Args:
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
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaRBACRole>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
