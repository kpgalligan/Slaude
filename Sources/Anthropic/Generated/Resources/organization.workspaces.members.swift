// Transformed from `anthropic.resources.organization.workspaces.members` (members.py).

import Foundation

public struct OrganizationWorkspacesMembersResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
    public func retrieve(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> WorkspaceMember {
        try await _retrieve(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<WorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(userID, "user_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/members/{user_id}", ["workspace_id": workspaceID, "user_id": userID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.members.retrieve")
        return try await client.requestResponse(WorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// Update Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: New workspace role for the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ userID: String, workspaceID: String, workspaceRole: WorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> WorkspaceMember {
        try await _update(userID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ userID: String, workspaceID: String, workspaceRole: WorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<WorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(userID, "user_id")
        var body = ParamsBuilder()
        try body.set("workspace_role", workspaceRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/members/{user_id}", ["workspace_id": workspaceID, "user_id": userID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.members.update")
        return try await client.requestResponse(WorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// List Workspace Members
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ workspaceID: String, afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<WorkspaceMember> {
        try await _list(workspaceID, afterID: afterID, beforeID: beforeID, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ workspaceID: String, afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<WorkspaceMember>> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("limit", limit)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/members", ["workspace_id": workspaceID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.members.list")
        return try await client.requestPageResponse(Page<WorkspaceMember>.self, options, stream: _mode == .stream)
    }

    /// Create Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: Role of the new Workspace Member. Cannot be `workspace_billing`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ workspaceID: String, userID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> WorkspaceMember {
        try await _add(workspaceID, userID: userID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ workspaceID: String, userID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<WorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var body = ParamsBuilder()
        try body.set("user_id", userID)
        try body.set("workspace_role", workspaceRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/members", ["workspace_id": workspaceID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.members.add")
        return try await client.requestResponse(WorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// Delete Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
    public func remove(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> MemberRemoveResponse {
        try await _remove(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<MemberRemoveResponse> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(userID, "user_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/members/{user_id}", ["workspace_id": workspaceID, "user_id": userID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.members.remove")
        return try await client.requestResponse(MemberRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationWorkspacesMembersResource

    /// Get Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
        public func retrieve(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<WorkspaceMember> {
            try await resource._retrieve(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: New workspace role for the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ userID: String, workspaceID: String, workspaceRole: WorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<WorkspaceMember> {
            try await resource._update(userID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Workspace Members
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ workspaceID: String, afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<WorkspaceMember>> {
            try await resource._list(workspaceID, afterID: afterID, beforeID: beforeID, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Create Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: Role of the new Workspace Member. Cannot be `workspace_billing`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ workspaceID: String, userID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<WorkspaceMember> {
            try await resource._add(workspaceID, userID: userID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
        public func remove(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<MemberRemoveResponse> {
            try await resource._remove(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationWorkspacesMembersResource

    /// Get Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
        public func retrieve<R: Sendable>(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<WorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: New workspace role for the User.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ userID: String, workspaceID: String, workspaceRole: WorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<WorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._update(userID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Workspace Members
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ workspaceID: String, afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<WorkspaceMember>>) async throws -> R) async throws -> R {
            let response = try await resource._list(workspaceID, afterID: afterID, beforeID: beforeID, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Create Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   user_id: ID of the User.
    ///
    ///   workspace_role: Role of the new Workspace Member. Cannot be `workspace_billing`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ workspaceID: String, userID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<WorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._add(workspaceID, userID: userID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete Workspace Member
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
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
        public func remove<R: Sendable>(_ userID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<MemberRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(userID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
