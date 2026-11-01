// Transformed from `anthropic.resources.organization.service_accounts.service_accounts` (service_accounts.py).

import Foundation

public struct OrganizationServiceAccountsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var workspaces: OrganizationServiceAccountsWorkspacesResource { OrganizationServiceAccountsWorkspacesResource(client: client) }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a service account.
    ///
    /// A service account is a named workload identity that federation rules target.
    /// `organization_role` is `developer` (default) or `admin`; a rule may only be
    /// created or retargeted to grant `org:admin` scope when the target's
    /// `organization_role` is `admin`. Creating an `admin`-role service account
    /// requires an interactive credential (a user OAuth token or a Console session) — a
    /// workload may only create `developer`-role service accounts.
    ///
    /// Args:
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   description: Optional free-text description.
    ///
    ///   organization_role: Org-level role. Defaults to `developer`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(name: String, description: String?? = nil, organizationRole: ServiceAccountCreateParams.OrganizationRole? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ServiceAccount {
        try await _create(name: name, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(name: String, description: String?? = nil, organizationRole: ServiceAccountCreateParams.OrganizationRole? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ServiceAccount> {
        var body = ParamsBuilder()
        try body.set("name", name)
        try body.set("description", description)
        try body.set("organization_role", organizationRole)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/service_accounts", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.create", spanRoute: "/v1/organizations/service_accounts", spanCreatedID: SpanCreatedID("anthropic.organization.service_account.id"))
        return try await client.requestResponse(ServiceAccount.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a service account by its ID (`svac_...`).
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ServiceAccount {
        try await _retrieve(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ServiceAccount> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}", ["service_account_id": serviceAccountID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.retrieve", spanRoute: "/v1/organizations/service_accounts/{service_account_id}", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID])
        return try await client.requestResponse(ServiceAccount.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Update a service account.
    ///
    /// Only `description` and `organization_role` are mutable; `name` cannot be
    /// changed. Archived service accounts cannot be updated; this returns 400. Setting
    /// `organization_role` to `admin` (even when unchanged) requires an interactive
    /// credential (a user OAuth token or a Console session).
    ///
    /// Args:
    ///   service_account_id: ID of the service account to update.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   organization_role: Replaces the org-level role. Omit or send `null` to leave unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ serviceAccountID: String, description: String?? = nil, organizationRole: ServiceAccountUpdateParams.OrganizationRole?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ServiceAccount {
        try await _update(serviceAccountID, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ serviceAccountID: String, description: String?? = nil, organizationRole: ServiceAccountUpdateParams.OrganizationRole?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ServiceAccount> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        var body = ParamsBuilder()
        try body.set("description", description)
        try body.set("organization_role", organizationRole)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}", ["service_account_id": serviceAccountID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.update", spanRoute: "/v1/organizations/service_accounts/{service_account_id}", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID])
        return try await client.requestResponse(ServiceAccount.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List service accounts in the caller's organization.
    ///
    /// Results are ordered by creation time, newest first. Use `limit` and the
    /// `next_page` cursor to paginate; set `include_archived=true` to include archived
    /// service accounts.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
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
    public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<ServiceAccount> {
        try await _list(includeArchived: includeArchived, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<ServiceAccount>> {
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/service_accounts", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.list", spanRoute: "/v1/organizations/service_accounts")
        return try await client.requestPageResponse(PageCursor<ServiceAccount>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a service account.
    ///
    /// Idempotent; re-archiving returns the service account with its original
    /// `archived_at`. Rejected with 400 if any live (non-archived) federation rule
    /// still targets this service account, same as issuer archival; archive those rules
    /// first or change their target to another service account.
    ///
    /// Args:
    ///   service_account_id: ID of the service account to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func archive(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ServiceAccount {
        try await _archive(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ServiceAccount> {
        try requireNonEmpty(serviceAccountID, "service_account_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/service_accounts/{service_account_id}/archive", ["service_account_id": serviceAccountID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.service_accounts.archive", spanRoute: "/v1/organizations/service_accounts/{service_account_id}/archive", spanAttributes: ["anthropic.organization.service_account.id": serviceAccountID])
        return try await client.requestResponse(ServiceAccount.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationServiceAccountsResource

        public var workspaces: OrganizationServiceAccountsWorkspacesResource.WithRawResponse { resource.workspaces.withRawResponse }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a service account.
    ///
    /// A service account is a named workload identity that federation rules target.
    /// `organization_role` is `developer` (default) or `admin`; a rule may only be
    /// created or retargeted to grant `org:admin` scope when the target's
    /// `organization_role` is `admin`. Creating an `admin`-role service account
    /// requires an interactive credential (a user OAuth token or a Console session) — a
    /// workload may only create `developer`-role service accounts.
    ///
    /// Args:
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   description: Optional free-text description.
    ///
    ///   organization_role: Org-level role. Defaults to `developer`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(name: String, description: String?? = nil, organizationRole: ServiceAccountCreateParams.OrganizationRole? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ServiceAccount> {
            try await resource._create(name: name, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a service account by its ID (`svac_...`).
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ServiceAccount> {
            try await resource._retrieve(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Update a service account.
    ///
    /// Only `description` and `organization_role` are mutable; `name` cannot be
    /// changed. Archived service accounts cannot be updated; this returns 400. Setting
    /// `organization_role` to `admin` (even when unchanged) requires an interactive
    /// credential (a user OAuth token or a Console session).
    ///
    /// Args:
    ///   service_account_id: ID of the service account to update.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   organization_role: Replaces the org-level role. Omit or send `null` to leave unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ serviceAccountID: String, description: String?? = nil, organizationRole: ServiceAccountUpdateParams.OrganizationRole?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ServiceAccount> {
            try await resource._update(serviceAccountID, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List service accounts in the caller's organization.
    ///
    /// Results are ordered by creation time, newest first. Use `limit` and the
    /// `next_page` cursor to paginate; set `include_archived=true` to include archived
    /// service accounts.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
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
        public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<ServiceAccount>> {
            try await resource._list(includeArchived: includeArchived, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a service account.
    ///
    /// Idempotent; re-archiving returns the service account with its original
    /// `archived_at`. Rejected with 400 if any live (non-archived) federation rule
    /// still targets this service account, same as issuer archival; archive those rules
    /// first or change their target to another service account.
    ///
    /// Args:
    ///   service_account_id: ID of the service account to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ServiceAccount> {
            try await resource._archive(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationServiceAccountsResource

        public var workspaces: OrganizationServiceAccountsWorkspacesResource.WithStreamingResponse { resource.workspaces.withStreamingResponse }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a service account.
    ///
    /// A service account is a named workload identity that federation rules target.
    /// `organization_role` is `developer` (default) or `admin`; a rule may only be
    /// created or retargeted to grant `org:admin` scope when the target's
    /// `organization_role` is `admin`. Creating an `admin`-role service account
    /// requires an interactive credential (a user OAuth token or a Console session) — a
    /// workload may only create `developer`-role service accounts.
    ///
    /// Args:
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   description: Optional free-text description.
    ///
    ///   organization_role: Org-level role. Defaults to `developer`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(name: String, description: String?? = nil, organizationRole: ServiceAccountCreateParams.OrganizationRole? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ServiceAccount>) async throws -> R) async throws -> R {
            let response = try await resource._create(name: name, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a service account by its ID (`svac_...`).
    ///
    /// Args:
    ///   service_account_id: ID of the service account.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ServiceAccount>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Update a service account.
    ///
    /// Only `description` and `organization_role` are mutable; `name` cannot be
    /// changed. Archived service accounts cannot be updated; this returns 400. Setting
    /// `organization_role` to `admin` (even when unchanged) requires an interactive
    /// credential (a user OAuth token or a Console session).
    ///
    /// Args:
    ///   service_account_id: ID of the service account to update.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   organization_role: Replaces the org-level role. Omit or send `null` to leave unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ serviceAccountID: String, description: String?? = nil, organizationRole: ServiceAccountUpdateParams.OrganizationRole?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ServiceAccount>) async throws -> R) async throws -> R {
            let response = try await resource._update(serviceAccountID, description: description, organizationRole: organizationRole, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List service accounts in the caller's organization.
    ///
    /// Results are ordered by creation time, newest first. Use `limit` and the
    /// `next_page` cursor to paginate; set `include_archived=true` to include archived
    /// service accounts.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
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
        public func list<R: Sendable>(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<ServiceAccount>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeArchived: includeArchived, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a service account.
    ///
    /// Idempotent; re-archiving returns the service account with its original
    /// `archived_at`. Rejected with 400 if any live (non-archived) federation rule
    /// still targets this service account, same as issuer archival; archive those rules
    /// first or change their target to another service account.
    ///
    /// Args:
    ///   service_account_id: ID of the service account to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive<R: Sendable>(_ serviceAccountID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ServiceAccount>) async throws -> R) async throws -> R {
            let response = try await resource._archive(serviceAccountID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
