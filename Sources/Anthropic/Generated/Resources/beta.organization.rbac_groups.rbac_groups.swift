// Transformed from `anthropic.resources.beta.organization.rbac_groups.rbac_groups` (rbac_groups.py).

import Foundation

public struct BetaOrganizationRbacGroupsRBACGroupsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var members: BetaOrganizationRbacGroupsMembersResource { BetaOrganizationRbacGroupsMembersResource(client: client) }

    /// Create an RBAC Group in the Claude Enterprise tenant.
    ///
    /// Groups created via the API
    /// have source type `"direct"`.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(name: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaRBACGroup {
        try await _create(name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(name: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaRBACGroup> {
        var body = ParamsBuilder()
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/rbac_groups", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.create", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaRBACGroup.self, options, stream: _mode == .stream)
    }

    /// Retrieve an RBAC Group by ID.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaRBACGroup {
        try await _retrieve(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaRBACGroup> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}", ["rbac_group_id": rbacGroupID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaRBACGroup.self, options, stream: _mode == .stream)
    }

    /// Update an RBAC Group's name.
    ///
    /// Groups provisioned by an identity provider (source
    /// type `"scim"`) cannot be modified via the API while an organization in the
    /// tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ rbacGroupID: String, name: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaRBACGroup {
        try await _update(rbacGroupID, name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ rbacGroupID: String, name: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaRBACGroup> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        var body = ParamsBuilder()
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}", ["rbac_group_id": rbacGroupID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.update", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaRBACGroup.self, options, stream: _mode == .stream)
    }

    /// List RBAC Groups in the Claude Enterprise tenant.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
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
    public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaRBACGroup> {
        try await _list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaRBACGroup>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/rbac_groups", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaRBACGroup>.self, options, stream: _mode == .stream)
    }

    /// Delete an RBAC Group.
    ///
    /// Groups provisioned by an identity provider (source type
    /// `"scim"`) cannot be deleted via the API while an organization in the tenant uses
    /// SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func delete(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> RBACGroupDeleteResponse {
        try await _delete(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<RBACGroupDeleteResponse> {
        try requireNonEmpty(rbacGroupID, "rbac_group_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/rbac_groups/{rbac_group_id}", ["rbac_group_id": rbacGroupID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rbac_groups.delete", qualifiers: ["beta": "true"])
        return try await client.requestResponse(RBACGroupDeleteResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationRbacGroupsRBACGroupsResource

        public var members: BetaOrganizationRbacGroupsMembersResource.WithRawResponse { resource.members.withRawResponse }

    /// Create an RBAC Group in the Claude Enterprise tenant.
    ///
    /// Groups created via the API
    /// have source type `"direct"`.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(name: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaRBACGroup> {
            try await resource._create(name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve an RBAC Group by ID.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaRBACGroup> {
            try await resource._retrieve(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update an RBAC Group's name.
    ///
    /// Groups provisioned by an identity provider (source
    /// type `"scim"`) cannot be modified via the API while an organization in the
    /// tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ rbacGroupID: String, name: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaRBACGroup> {
            try await resource._update(rbacGroupID, name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List RBAC Groups in the Claude Enterprise tenant.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
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
        public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaRBACGroup>> {
            try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete an RBAC Group.
    ///
    /// Groups provisioned by an identity provider (source type
    /// `"scim"`) cannot be deleted via the API while an organization in the tenant uses
    /// SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<RBACGroupDeleteResponse> {
            try await resource._delete(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationRbacGroupsRBACGroupsResource

        public var members: BetaOrganizationRbacGroupsMembersResource.WithStreamingResponse { resource.members.withStreamingResponse }

    /// Create an RBAC Group in the Claude Enterprise tenant.
    ///
    /// Groups created via the API
    /// have source type `"direct"`.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(name: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaRBACGroup>) async throws -> R) async throws -> R {
            let response = try await resource._create(name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve an RBAC Group by ID.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaRBACGroup>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update an RBAC Group's name.
    ///
    /// Groups provisioned by an identity provider (source
    /// type `"scim"`) cannot be modified via the API while an organization in the
    /// tenant uses SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   name: Name of the RBAC Group. Not uniqueness-enforced.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ rbacGroupID: String, name: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaRBACGroup>) async throws -> R) async throws -> R {
            let response = try await resource._update(rbacGroupID, name: name, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List RBAC Groups in the Claude Enterprise tenant.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
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
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaRBACGroup>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete an RBAC Group.
    ///
    /// Groups provisioned by an identity provider (source type
    /// `"scim"`) cannot be deleted via the API while an organization in the tenant uses
    /// SCIM provisioning.
    ///
    /// The RBAC Groups API is available to Claude Enterprise organizations only.
    ///
    /// Args:
    ///   rbac_group_id: ID of the RBAC Group.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete<R: Sendable>(_ rbacGroupID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<RBACGroupDeleteResponse>) async throws -> R) async throws -> R {
            let response = try await resource._delete(rbacGroupID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
