// Transformed from `anthropic.resources.beta.organization.workspaces.service_accounts` (service_accounts.py).

import Foundation

public struct BetaOrganizationWorkspacesServiceAccountsResource: Sendable {
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
    /// Retrieve a service account's membership in a workspace.
    ///
    /// Returns the membership record, including the service account's `workspace_role`
    /// in this workspace. Archived workspaces return 400. For the default workspace,
    /// returns the implicit (`implicit: true`) membership when no explicit membership
    /// exists; an explicitly added membership is returned with its assigned role. An
    /// archived service account returns 404.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaServiceAccountWorkspaceMember {
        try await _retrieve(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(serviceAccountID, "service_account_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", ["workspace_id": workspaceID, "service_account_id": serviceAccountID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.service_accounts.retrieve", spanRoute: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID, "anthropic.organization.workspace.service_account.id": serviceAccountID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaServiceAccountWorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Change a service account's role in a workspace.
    ///
    /// The new `workspace_role` replaces the current one. Only explicit memberships can
    /// be updated; to set a role on the implicit default-workspace membership, add the
    /// service account explicitly with
    /// `POST /workspaces/{workspace_id}/service_accounts`. Archived workspaces
    /// return 400. Archived service accounts cannot be updated and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_role: New role for the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ serviceAccountID: String, workspaceID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaServiceAccountWorkspaceMember {
        try await _update(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ serviceAccountID: String, workspaceID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(serviceAccountID, "service_account_id")
        var body = ParamsBuilder()
        try body.set("workspace_role", workspaceRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", ["workspace_id": workspaceID, "service_account_id": serviceAccountID]), body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.service_accounts.update", spanRoute: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID, "anthropic.organization.workspace.service_account.id": serviceAccountID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaServiceAccountWorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the service accounts that are members of a workspace.
    ///
    /// Each entry includes the service account's `workspace_role`. Use `limit` and the
    /// `next_page` cursor to paginate. Archived workspaces return 400; use
    /// `GET /service_accounts/{id}/workspaces` to audit memberships of an archived
    /// workspace. The implicit default-workspace membership is not included in this
    /// list. Memberships of archived service accounts are omitted from the results.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ workspaceID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaServiceAccountWorkspaceMember> {
        try await _list(workspaceID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ workspaceID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaServiceAccountWorkspaceMember>> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/service_accounts", ["workspace_id": workspaceID]), query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.service_accounts.list", spanRoute: "/v1/organizations/workspaces/{workspace_id}/service_accounts", spanAttributes: ["anthropic.organization.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaServiceAccountWorkspaceMember>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Add a service account to a workspace with the given `workspace_role`.
    ///
    /// The role determines what the service account can do in the workspace and which
    /// workspace-scoped permissions it can be granted when authenticating through
    /// federation. Every service account is already an implicit `workspace_user` member
    /// of the default workspace; adding it explicitly assigns a chosen role. If the
    /// service account is already an explicit member of the workspace, its
    /// `workspace_role` is replaced with the value supplied here. Archived workspaces
    /// return 400. Archived service accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: Tagged service account ID to add.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ workspaceID: String, serviceAccountID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaServiceAccountWorkspaceMember {
        try await _add(workspaceID, serviceAccountID: serviceAccountID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ workspaceID: String, serviceAccountID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var body = ParamsBuilder()
        try body.set("service_account_id", serviceAccountID)
        try body.set("workspace_role", workspaceRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/service_accounts", ["workspace_id": workspaceID]), body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.service_accounts.add", spanRoute: "/v1/organizations/workspaces/{workspace_id}/service_accounts", spanAttributes: ["anthropic.organization.workspace.id": workspaceID], spanCreatedID: SpanCreatedID("anthropic.organization.workspace.service_account.id", field: "service_account_id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaServiceAccountWorkspaceMember.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Remove a service account from a workspace.
    ///
    /// Removal is idempotent (returns 200 even if the membership was already removed).
    /// A DELETE against the implicit default-workspace membership returns 200 but is a
    /// no-op and the membership persists; deleting an explicit default-workspace row
    /// reverts to the implicit `workspace_user` membership. Archived workspaces
    /// return 400.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationWorkspacesServiceAccountRemoveResponse {
        try await _remove(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationWorkspacesServiceAccountRemoveResponse> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(serviceAccountID, "service_account_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", ["workspace_id": workspaceID, "service_account_id": serviceAccountID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.service_accounts.remove", spanRoute: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID, "anthropic.organization.workspace.service_account.id": serviceAccountID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationWorkspacesServiceAccountRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationWorkspacesServiceAccountsResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a service account's membership in a workspace.
    ///
    /// Returns the membership record, including the service account's `workspace_role`
    /// in this workspace. Archived workspaces return 400. For the default workspace,
    /// returns the implicit (`implicit: true`) membership when no explicit membership
    /// exists; an explicitly added membership is returned with its assigned role. An
    /// archived service account returns 404.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
            try await resource._retrieve(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Change a service account's role in a workspace.
    ///
    /// The new `workspace_role` replaces the current one. Only explicit memberships can
    /// be updated; to set a role on the implicit default-workspace membership, add the
    /// service account explicitly with
    /// `POST /workspaces/{workspace_id}/service_accounts`. Archived workspaces
    /// return 400. Archived service accounts cannot be updated and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_role: New role for the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ serviceAccountID: String, workspaceID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
            try await resource._update(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the service accounts that are members of a workspace.
    ///
    /// Each entry includes the service account's `workspace_role`. Use `limit` and the
    /// `next_page` cursor to paginate. Archived workspaces return 400; use
    /// `GET /service_accounts/{id}/workspaces` to audit memberships of an archived
    /// workspace. The implicit default-workspace membership is not included in this
    /// list. Memberships of archived service accounts are omitted from the results.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ workspaceID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaServiceAccountWorkspaceMember>> {
            try await resource._list(workspaceID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Add a service account to a workspace with the given `workspace_role`.
    ///
    /// The role determines what the service account can do in the workspace and which
    /// workspace-scoped permissions it can be granted when authenticating through
    /// federation. Every service account is already an implicit `workspace_user` member
    /// of the default workspace; adding it explicitly assigns a chosen role. If the
    /// service account is already an explicit member of the workspace, its
    /// `workspace_role` is replaced with the value supplied here. Archived workspaces
    /// return 400. Archived service accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: Tagged service account ID to add.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ workspaceID: String, serviceAccountID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaServiceAccountWorkspaceMember> {
            try await resource._add(workspaceID, serviceAccountID: serviceAccountID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Remove a service account from a workspace.
    ///
    /// Removal is idempotent (returns 200 even if the membership was already removed).
    /// A DELETE against the implicit default-workspace membership returns 200 but is a
    /// no-op and the membership persists; deleting an explicit default-workspace row
    /// reverts to the implicit `workspace_user` membership. Archived workspaces
    /// return 400.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationWorkspacesServiceAccountRemoveResponse> {
            try await resource._remove(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationWorkspacesServiceAccountsResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a service account's membership in a workspace.
    ///
    /// Returns the membership record, including the service account's `workspace_role`
    /// in this workspace. Archived workspaces return 400. For the default workspace,
    /// returns the implicit (`implicit: true`) membership when no explicit membership
    /// exists; an explicitly added membership is returned with its assigned role. An
    /// archived service account returns 404.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaServiceAccountWorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Change a service account's role in a workspace.
    ///
    /// The new `workspace_role` replaces the current one. Only explicit memberships can
    /// be updated; to set a role on the implicit default-workspace membership, add the
    /// service account explicitly with
    /// `POST /workspaces/{workspace_id}/service_accounts`. Archived workspaces
    /// return 400. Archived service accounts cannot be updated and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   workspace_role: New role for the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ serviceAccountID: String, workspaceID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaServiceAccountWorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._update(serviceAccountID, workspaceID: workspaceID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List the service accounts that are members of a workspace.
    ///
    /// Each entry includes the service account's `workspace_role`. Use `limit` and the
    /// `next_page` cursor to paginate. Archived workspaces return 400; use
    /// `GET /service_accounts/{id}/workspaces` to audit memberships of an archived
    /// workspace. The implicit default-workspace membership is not included in this
    /// list. Memberships of archived service accounts are omitted from the results.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ workspaceID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaServiceAccountWorkspaceMember>>) async throws -> R) async throws -> R {
            let response = try await resource._list(workspaceID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    /// The role determines what the service account can do in the workspace and which
    /// workspace-scoped permissions it can be granted when authenticating through
    /// federation. Every service account is already an implicit `workspace_user` member
    /// of the default workspace; adding it explicitly assigns a chosen role. If the
    /// service account is already an explicit member of the workspace, its
    /// `workspace_role` is replaced with the value supplied here. Archived workspaces
    /// return 400. Archived service accounts cannot be added and are rejected.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: Tagged service account ID to add.
    ///
    ///   workspace_role: Role to assign to the service account in this workspace.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ workspaceID: String, serviceAccountID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaServiceAccountWorkspaceMember>) async throws -> R) async throws -> R {
            let response = try await resource._add(workspaceID, serviceAccountID: serviceAccountID, workspaceRole: workspaceRole, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    /// Removal is idempotent (returns 200 even if the membership was already removed).
    /// A DELETE against the implicit default-workspace membership returns 200 but is a
    /// no-op and the membership persists; deleting an explicit default-workspace row
    /// reverts to the implicit `workspace_user` membership. Archived workspaces
    /// return 400.
    ///
    /// Args:
    ///   workspace_id: ID of the workspace.
    ///
    ///   service_account_id: ID of the service account.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ serviceAccountID: String, workspaceID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationWorkspacesServiceAccountRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(serviceAccountID, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
