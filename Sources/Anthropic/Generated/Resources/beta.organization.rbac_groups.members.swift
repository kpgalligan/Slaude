// Transformed from `anthropic.resources.beta.organization.rbac_groups.members` (members.py).

import Foundation

public struct BetaOrganizationRbacGroupsMembersResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List members of an RBAC Group.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
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
    public func list(_ rbacGroupID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaRBACGroupMember> {
        try await _list(rbacGroupID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ rbacGroupID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaRBACGroupMember>> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}/members", ["rbac_group_id": rbacGroupID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.members.list")
        return try await client.requestPageResponse(PageCursor<BetaRBACGroupMember>.self, options, stream: _mode == .stream)
    }

    /// Add a User to an RBAC Group.
    ///
    /// Membership of groups provisioned by an identity
    /// provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ rbacGroupID: String, userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaRBACGroupMember {
        try await _add(rbacGroupID, userID: userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ rbacGroupID: String, userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaRBACGroupMember> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        var body = ParamsBuilder()
        try body.set("user_id", userID)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}/members", ["rbac_group_id": rbacGroupID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.members.add")
        return try await client.requestResponse(BetaRBACGroupMember.self, options, stream: _mode == .stream)
    }

    /// Remove a User from an RBAC Group.
    ///
    /// Membership of groups provisioned by an
    /// identity provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ userID: String, rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationRbacGroupsMemberRemoveResponse {
        try await _remove(userID, rbacGroupID: rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ userID: String, rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationRbacGroupsMemberRemoveResponse> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        try requireNonEmpty(userID, "user_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}/members/{user_id}", ["rbac_group_id": rbacGroupID, "user_id": userID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.members.remove")
        return try await client.requestResponse(BetaOrganizationRbacGroupsMemberRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationRbacGroupsMembersResource

    /// List members of an RBAC Group.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
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
        public func list(_ rbacGroupID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaRBACGroupMember>> {
            try await resource._list(rbacGroupID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Add a User to an RBAC Group.
    ///
    /// Membership of groups provisioned by an identity
    /// provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ rbacGroupID: String, userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaRBACGroupMember> {
            try await resource._add(rbacGroupID, userID: userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Remove a User from an RBAC Group.
    ///
    /// Membership of groups provisioned by an
    /// identity provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ userID: String, rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationRbacGroupsMemberRemoveResponse> {
            try await resource._remove(userID, rbacGroupID: rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationRbacGroupsMembersResource

    /// List members of an RBAC Group.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
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
        public func list<R: Sendable>(_ rbacGroupID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaRBACGroupMember>>) async throws -> R) async throws -> R {
            let response = try await resource._list(rbacGroupID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Add a User to an RBAC Group.
    ///
    /// Membership of groups provisioned by an identity
    /// provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ rbacGroupID: String, userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaRBACGroupMember>) async throws -> R) async throws -> R {
            let response = try await resource._add(rbacGroupID, userID: userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Remove a User from an RBAC Group.
    ///
    /// Membership of groups provisioned by an
    /// identity provider (source type `"scim"`) cannot be modified via the API while an
    /// organization in the tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ userID: String, rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationRbacGroupsMemberRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(userID, rbacGroupID: rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
