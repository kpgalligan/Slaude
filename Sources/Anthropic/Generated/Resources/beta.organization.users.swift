// Transformed from `anthropic.resources.beta.organization.users` (users.py).

import Foundation

public struct BetaOrganizationUsersResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Retrieve a member of the organization by user ID.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationUser {
        try await _retrieve(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationUser> {
        try requireNonEmpty(userID, "user_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/users/{user_id}", ["user_id": userID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.users.retrieve", spanRoute: "/v1/organizations/users/{user_id}", spanAttributes: ["anthropic.organization.user.id": userID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationUser.self, options, stream: _mode == .stream)
    }

    /// Update a member's organization role.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   role: New role for the User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; changing a User's role to `managed` requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ userID: String, role: BetaOrganizationUserUpdateParams.Role, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationUser {
        try await _update(userID, role: role, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ userID: String, role: BetaOrganizationUserUpdateParams.Role, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationUser> {
        try requireNonEmpty(userID, "user_id")
        var body = ParamsBuilder()
        try body.set("role", role)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/users/{user_id}", ["user_id": userID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.users.update", spanRoute: "/v1/organizations/users/{user_id}", spanAttributes: ["anthropic.organization.user.id": userID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationUser.self, options, stream: _mode == .stream)
    }

    /// List the organization's members.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by user email.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   roles: Filter to items whose `role` equals one of the supplied values. Repeatable;
    ///       values are OR'ed together.
    ///
    ///       Accepted values depend on the organization type: Console and API organizations
    ///       accept `user`, `developer`, `billing`, `admin`, and `claude_code_user`; Claude
    ///       Enterprise organizations accept `user`, `owner`, `primary_owner`,
    ///       `membership_admin`, and `managed`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaOrganizationUser> {
        try await _list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaOrganizationUser>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("email", email)
        try query.set("limit", limit)
        try query.set("roles", roles)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/users", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.users.list", spanRoute: "/v1/organizations/users", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(Page<BetaOrganizationUser>.self, options, stream: _mode == .stream)
    }

    /// Remove a member from the organization.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationUserRemoveResponse {
        try await _remove(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationUserRemoveResponse> {
        try requireNonEmpty(userID, "user_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/users/{user_id}", ["user_id": userID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.users.remove", spanRoute: "/v1/organizations/users/{user_id}", spanAttributes: ["anthropic.organization.user.id": userID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationUserRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationUsersResource

    /// Retrieve a member of the organization by user ID.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationUser> {
            try await resource._retrieve(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update a member's organization role.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   role: New role for the User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; changing a User's role to `managed` requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ userID: String, role: BetaOrganizationUserUpdateParams.Role, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationUser> {
            try await resource._update(userID, role: role, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's members.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by user email.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   roles: Filter to items whose `role` equals one of the supplied values. Repeatable;
    ///       values are OR'ed together.
    ///
    ///       Accepted values depend on the organization type: Console and API organizations
    ///       accept `user`, `developer`, `billing`, `admin`, and `claude_code_user`; Claude
    ///       Enterprise organizations accept `user`, `owner`, `primary_owner`,
    ///       `membership_admin`, and `managed`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaOrganizationUser>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Remove a member from the organization.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationUserRemoveResponse> {
            try await resource._remove(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationUsersResource

    /// Retrieve a member of the organization by user ID.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationUser>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update a member's organization role.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   role: New role for the User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; changing a User's role to `managed` requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ userID: String, role: BetaOrganizationUserUpdateParams.Role, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationUser>) async throws -> R) async throws -> R {
            let response = try await resource._update(userID, role: role, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's members.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by user email.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   roles: Filter to items whose `role` equals one of the supplied values. Repeatable;
    ///       values are OR'ed together.
    ///
    ///       Accepted values depend on the organization type: Console and API organizations
    ///       accept `user`, `developer`, `billing`, `admin`, and `claude_code_user`; Claude
    ///       Enterprise organizations accept `user`, `owner`, `primary_owner`,
    ///       `membership_admin`, and `managed`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaOrganizationUser>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Remove a member from the organization.
    ///
    /// Args:
    ///   user_id: ID of the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ userID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationUserRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(userID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
