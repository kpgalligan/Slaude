// Transformed from `anthropic.resources.organization.invites` (invites.py).

import Foundation

public struct OrganizationInvitesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Invite a user to join the organization by email.
    ///
    /// On plans that draw members from a finite pool of purchased seats, the invite
    /// automatically consumes a seat from the lowest tier with availability; there is
    /// no seat-tier parameter. When no seat is free the request fails with a 400 error
    /// rather than purchasing a seat.
    ///
    /// Args:
    ///   email: Email of the User.
    ///
    ///   role: Role for the invited User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; inviting with the `managed` role requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   rbac_group_ids: RBAC group IDs to assign to the User when the Invite is accepted. A non-empty
    ///       array is accepted only for a Claude Enterprise organization with RBAC groups,
    ///       and requires the key to carry the `write:rbac_groups` scope.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(email: String, role: InviteCreateParams.Role, rbacGroupIDs: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationInvite {
        try await _create(email: email, role: role, rbacGroupIDs: rbacGroupIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(email: String, role: InviteCreateParams.Role, rbacGroupIDs: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationInvite> {
        var body = ParamsBuilder()
        try body.set("email", email)
        try body.set("role", role)
        try body.set("rbac_group_ids", rbacGroupIDs)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/invites", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.invites.create", spanRoute: "/v1/organizations/invites", spanCreatedID: SpanCreatedID("anthropic.organization.invite.id"))
        return try await client.requestResponse(OrganizationInvite.self, options, stream: _mode == .stream)
    }

    /// Retrieve an invite by ID.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationInvite {
        try await _retrieve(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationInvite> {
        try requireNonEmpty(inviteID, "invite_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/invites/{invite_id}", ["invite_id": inviteID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.invites.retrieve", spanRoute: "/v1/organizations/invites/{invite_id}", spanAttributes: ["anthropic.organization.invite.id": inviteID])
        return try await client.requestResponse(OrganizationInvite.self, options, stream: _mode == .stream)
    }

    /// List the organization's invites.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by the email address the Invite was sent to. Matches the same way as the
    ///       Users list's `email` filter (normalized, case-insensitive).
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
    ///   statuses: Filter by Invite status. Repeatable; values are OR'ed together. Omit to return
    ///       `pending`, `accepted`, and `expired` Invites alike.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, statuses: [InviteListParams.Statuses]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<OrganizationInvite> {
        try await _list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, statuses: statuses, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, statuses: [InviteListParams.Statuses]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<OrganizationInvite>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("email", email)
        try query.set("limit", limit)
        try query.set("roles", roles)
        try query.set("statuses", statuses)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/invites", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.invites.list", spanRoute: "/v1/organizations/invites")
        return try await client.requestPageResponse(Page<OrganizationInvite>.self, options, stream: _mode == .stream)
    }

    /// Delete a pending invite.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func delete(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> InviteDeleteResponse {
        try await _delete(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<InviteDeleteResponse> {
        try requireNonEmpty(inviteID, "invite_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/invites/{invite_id}", ["invite_id": inviteID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.invites.delete", spanRoute: "/v1/organizations/invites/{invite_id}", spanAttributes: ["anthropic.organization.invite.id": inviteID])
        return try await client.requestResponse(InviteDeleteResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationInvitesResource

    /// Invite a user to join the organization by email.
    ///
    /// On plans that draw members from a finite pool of purchased seats, the invite
    /// automatically consumes a seat from the lowest tier with availability; there is
    /// no seat-tier parameter. When no seat is free the request fails with a 400 error
    /// rather than purchasing a seat.
    ///
    /// Args:
    ///   email: Email of the User.
    ///
    ///   role: Role for the invited User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; inviting with the `managed` role requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   rbac_group_ids: RBAC group IDs to assign to the User when the Invite is accepted. A non-empty
    ///       array is accepted only for a Claude Enterprise organization with RBAC groups,
    ///       and requires the key to carry the `write:rbac_groups` scope.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(email: String, role: InviteCreateParams.Role, rbacGroupIDs: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationInvite> {
            try await resource._create(email: email, role: role, rbacGroupIDs: rbacGroupIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve an invite by ID.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationInvite> {
            try await resource._retrieve(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's invites.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by the email address the Invite was sent to. Matches the same way as the
    ///       Users list's `email` filter (normalized, case-insensitive).
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
    ///   statuses: Filter by Invite status. Repeatable; values are OR'ed together. Omit to return
    ///       `pending`, `accepted`, and `expired` Invites alike.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, statuses: [InviteListParams.Statuses]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<OrganizationInvite>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, statuses: statuses, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a pending invite.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<InviteDeleteResponse> {
            try await resource._delete(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationInvitesResource

    /// Invite a user to join the organization by email.
    ///
    /// On plans that draw members from a finite pool of purchased seats, the invite
    /// automatically consumes a seat from the lowest tier with availability; there is
    /// no seat-tier parameter. When no seat is free the request fails with a 400 error
    /// rather than purchasing a seat.
    ///
    /// Args:
    ///   email: Email of the User.
    ///
    ///   role: Role for the invited User.
    ///
    ///       The accepted values depend on the organization type. Console and API
    ///       organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    ///       `admin` cannot be assigned through the API. Claude Enterprise organizations
    ///       accept `user` and `managed`; inviting with the `managed` role requires the
    ///       `write:rbac_groups` scope in addition to `write:members`.
    ///
    ///   rbac_group_ids: RBAC group IDs to assign to the User when the Invite is accepted. A non-empty
    ///       array is accepted only for a Claude Enterprise organization with RBAC groups,
    ///       and requires the key to carry the `write:rbac_groups` scope.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(email: String, role: InviteCreateParams.Role, rbacGroupIDs: [String]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationInvite>) async throws -> R) async throws -> R {
            let response = try await resource._create(email: email, role: role, rbacGroupIDs: rbacGroupIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve an invite by ID.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationInvite>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's invites.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   email: Filter by the email address the Invite was sent to. Matches the same way as the
    ///       Users list's `email` filter (normalized, case-insensitive).
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
    ///   statuses: Filter by Invite status. Repeatable; values are OR'ed together. Omit to return
    ///       `pending`, `accepted`, and `expired` Invites alike.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, statuses: [InviteListParams.Statuses]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<OrganizationInvite>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, email: email, limit: limit, roles: roles, statuses: statuses, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a pending invite.
    ///
    /// Args:
    ///   invite_id: ID of the Invite.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete<R: Sendable>(_ inviteID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<InviteDeleteResponse>) async throws -> R) async throws -> R {
            let response = try await resource._delete(inviteID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
