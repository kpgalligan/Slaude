// Transformed from `anthropic.resources.organization.service_accounts.workspaces` (workspaces.py).

import Foundation

public struct OrganizationServiceAccountsWorkspacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the workspaces a service account is a member of.
    ///
    /// Each entry includes the service account's `workspace_role` in that workspace.
    /// Use `limit` and the `next_page` cursor to paginate. When the service account has
    /// no explicit default-workspace membership, the implicit (`implicit: true`)
    /// membership is returned as the first entry on the first page; with `limit=1` the
    /// first page may return up to 2 entries (the implicit entry plus one explicit
    /// membership) so a pagination cursor can be derived. Memberships are returned only
    /// while the service account is active. Without a `page` cursor, an archived
    /// service account returns an empty list. A `page` cursor that does not match an
    /// active membership returns a 400 invalid-request error. A cursor stops matching
    /// when the membership is removed, the workspace is deleted, or the service account
    /// is archived. Restart pagination from the first page to recover.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ serviceAccountID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<ServiceAccountWorkspaceMember> {
        try await _list(serviceAccountID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ serviceAccountID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<ServiceAccountWorkspaceMember>> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}/workspaces", ["service_account_id": serviceAccountID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.workspaces.list", spanRoute: "/v1/organizations/service_accounts/{service_account_id}/workspaces", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID])
        return try await client.requestPageResponse(PageCursor<ServiceAccountWorkspaceMember>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Add a service account to a workspace with the given `workspace_role`.
    ///
    /// Mirror of `POST /workspaces/{workspace_id}/service_accounts`, addressed from the
    /// service-account side; both create the same membership. If the service account is
    /// already an explicit member of the workspace, its `workspace_role` is replaced
    /// with the value supplied here. Archived workspaces return 400. Archived service
    /// accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: Tagged workspace ID to add the service account to.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ serviceAccountID: String, workspaceID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ServiceAccountWorkspaceMember {
        try await _add(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ serviceAccountID: String, workspaceID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ServiceAccountWorkspaceMember> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        var body = ParamsBuilder()
        try body.set("workspace_id", workspaceID)
        try body.set("workspace_role", workspaceRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}/workspaces", ["service_account_id": serviceAccountID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.workspaces.add", spanRoute: "/v1/organizations/service_accounts/{service_account_id}/workspaces", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID], spanCreatedID: SpanCreatedID("anthropic.organization.service_account.workspace.id", field: "workspace_id"))
        return try await client.requestResponse(ServiceAccountWorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Remove a service account from a workspace.
    ///
    /// Mirror of
    /// `DELETE /workspaces/{workspace_id}/service_accounts/{service_account_id}`,
    /// addressed from the service-account side. Removal is idempotent (returns 200 even
    /// if the membership was already removed). A DELETE against the implicit
    /// default-workspace membership returns 200 but is a no-op and the membership
    /// persists; deleting an explicit default-workspace row reverts to the implicit
    /// `workspace_user` membership. Archived workspaces return 400.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: ID of the workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ workspaceID: String, serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> WorkspaceRemoveResponse {
        try await _remove(workspaceID, serviceAccountID: serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ workspaceID: String, serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<WorkspaceRemoveResponse> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}/workspaces/{workspace_id}", ["service_account_id": serviceAccountID, "workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.workspaces.remove", spanRoute: "/v1/organizations/service_accounts/{service_account_id}/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID, "anthropic.organization.service_account.workspace.id": workspaceID])
        return try await client.requestResponse(WorkspaceRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationServiceAccountsWorkspacesResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the workspaces a service account is a member of.
    ///
    /// Each entry includes the service account's `workspace_role` in that workspace.
    /// Use `limit` and the `next_page` cursor to paginate. When the service account has
    /// no explicit default-workspace membership, the implicit (`implicit: true`)
    /// membership is returned as the first entry on the first page; with `limit=1` the
    /// first page may return up to 2 entries (the implicit entry plus one explicit
    /// membership) so a pagination cursor can be derived. Memberships are returned only
    /// while the service account is active. Without a `page` cursor, an archived
    /// service account returns an empty list. A `page` cursor that does not match an
    /// active membership returns a 400 invalid-request error. A cursor stops matching
    /// when the membership is removed, the workspace is deleted, or the service account
    /// is archived. Restart pagination from the first page to recover.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ serviceAccountID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<ServiceAccountWorkspaceMember>> {
            try await resource._list(serviceAccountID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Add a service account to a workspace with the given `workspace_role`.
    ///
    /// Mirror of `POST /workspaces/{workspace_id}/service_accounts`, addressed from the
    /// service-account side; both create the same membership. If the service account is
    /// already an explicit member of the workspace, its `workspace_role` is replaced
    /// with the value supplied here. Archived workspaces return 400. Archived service
    /// accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: Tagged workspace ID to add the service account to.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ serviceAccountID: String, workspaceID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ServiceAccountWorkspaceMember> {
            try await resource._add(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Remove a service account from a workspace.
    ///
    /// Mirror of
    /// `DELETE /workspaces/{workspace_id}/service_accounts/{service_account_id}`,
    /// addressed from the service-account side. Removal is idempotent (returns 200 even
    /// if the membership was already removed). A DELETE against the implicit
    /// default-workspace membership returns 200 but is a no-op and the membership
    /// persists; deleting an explicit default-workspace row reverts to the implicit
    /// `workspace_user` membership. Archived workspaces return 400.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: ID of the workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ workspaceID: String, serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<WorkspaceRemoveResponse> {
            try await resource._remove(workspaceID, serviceAccountID: serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationServiceAccountsWorkspacesResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the workspaces a service account is a member of.
    ///
    /// Each entry includes the service account's `workspace_role` in that workspace.
    /// Use `limit` and the `next_page` cursor to paginate. When the service account has
    /// no explicit default-workspace membership, the implicit (`implicit: true`)
    /// membership is returned as the first entry on the first page; with `limit=1` the
    /// first page may return up to 2 entries (the implicit entry plus one explicit
    /// membership) so a pagination cursor can be derived. Memberships are returned only
    /// while the service account is active. Without a `page` cursor, an archived
    /// service account returns an empty list. A `page` cursor that does not match an
    /// active membership returns a 400 invalid-request error. A cursor stops matching
    /// when the membership is removed, the workspace is deleted, or the service account
    /// is archived. Restart pagination from the first page to recover.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ serviceAccountID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<ServiceAccountWorkspaceMember>>) async throws -> R) async throws -> R {
            let response = try await resource._list(serviceAccountID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Add a service account to a workspace with the given `workspace_role`.
    ///
    /// Mirror of `POST /workspaces/{workspace_id}/service_accounts`, addressed from the
    /// service-account side; both create the same membership. If the service account is
    /// already an explicit member of the workspace, its `workspace_role` is replaced
    /// with the value supplied here. Archived workspaces return 400. Archived service
    /// accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: Tagged workspace ID to add the service account to.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ serviceAccountID: String, workspaceID: String, workspaceRole: NoBillingWorkspaceRole, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ServiceAccountWorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._add(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Remove a service account from a workspace.
    ///
    /// Mirror of
    /// `DELETE /workspaces/{workspace_id}/service_accounts/{service_account_id}`,
    /// addressed from the service-account side. Removal is idempotent (returns 200 even
    /// if the membership was already removed). A DELETE against the implicit
    /// default-workspace membership returns 200 but is a no-op and the membership
    /// persists; deleting an explicit default-workspace row reverts to the implicit
    /// `workspace_user` membership. Archived workspaces return 400.
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_id: ID of the workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ workspaceID: String, serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<WorkspaceRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(workspaceID, serviceAccountID: serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
