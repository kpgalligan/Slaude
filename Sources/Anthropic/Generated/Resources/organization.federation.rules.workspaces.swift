// Transformed from `anthropic.resources.organization.federation.rules.workspaces` (workspaces.py).

import Foundation

public struct OrganizationFederationRulesWorkspacesResource: Sendable {
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
    /// List workspaces where this federation rule is enabled.
    ///
    /// Returns all workspace enablements in a single response; the `limit` and `page`
    /// parameters are accepted but have no effect, and `next_page` is always `null`.
    /// Returns explicit per-workspace enablements only; for rules with
    /// `applies_to_all_workspaces` or a legacy single `workspace_id`, check those
    /// fields on the rule itself.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
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
    public func list(_ federationRuleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<FederationRuleWorkspace> {
        try await _list(federationRuleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ federationRuleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<FederationRuleWorkspace>> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}/workspaces", ["federation_rule_id": federationRuleID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.workspaces.list")
        return try await client.requestPageResponse(PageCursor<FederationRuleWorkspace>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Enable a federation rule for a workspace.
    ///
    /// Idempotent; re-enabling returns the existing enablement. The rule and workspace
    /// must both belong to your organization. Membership of the rule's target service
    /// account in this workspace is not checked at enablement: token exchange into this
    /// workspace is rejected unless the target is a member (it is implicitly a member
    /// of the default workspace). Archived rules are rejected with 400. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ federationRuleID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FederationRuleWorkspace {
        try await _add(federationRuleID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ federationRuleID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FederationRuleWorkspace> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        var body = ParamsBuilder()
        try body.set("workspace_id", workspaceID)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}/workspaces", ["federation_rule_id": federationRuleID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.workspaces.add")
        return try await client.requestResponse(FederationRuleWorkspace.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Disable a federation rule for a workspace.
    ///
    /// Idempotent; succeeds even if the enablement was already removed. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: ID of the workspace to disable for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ workspaceID: String, federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationFederationRulesWorkspaceRemoveResponse {
        try await _remove(workspaceID, federationRuleID: federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ workspaceID: String, federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationFederationRulesWorkspaceRemoveResponse> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}/workspaces/{workspace_id}", ["federation_rule_id": federationRuleID, "workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.workspaces.remove")
        return try await client.requestResponse(OrganizationFederationRulesWorkspaceRemoveResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationFederationRulesWorkspacesResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List workspaces where this federation rule is enabled.
    ///
    /// Returns all workspace enablements in a single response; the `limit` and `page`
    /// parameters are accepted but have no effect, and `next_page` is always `null`.
    /// Returns explicit per-workspace enablements only; for rules with
    /// `applies_to_all_workspaces` or a legacy single `workspace_id`, check those
    /// fields on the rule itself.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
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
        public func list(_ federationRuleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<FederationRuleWorkspace>> {
            try await resource._list(federationRuleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Enable a federation rule for a workspace.
    ///
    /// Idempotent; re-enabling returns the existing enablement. The rule and workspace
    /// must both belong to your organization. Membership of the rule's target service
    /// account in this workspace is not checked at enablement: token exchange into this
    /// workspace is rejected unless the target is a member (it is implicitly a member
    /// of the default workspace). Archived rules are rejected with 400. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ federationRuleID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FederationRuleWorkspace> {
            try await resource._add(federationRuleID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Disable a federation rule for a workspace.
    ///
    /// Idempotent; succeeds even if the enablement was already removed. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: ID of the workspace to disable for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ workspaceID: String, federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationFederationRulesWorkspaceRemoveResponse> {
            try await resource._remove(workspaceID, federationRuleID: federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationFederationRulesWorkspacesResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List workspaces where this federation rule is enabled.
    ///
    /// Returns all workspace enablements in a single response; the `limit` and `page`
    /// parameters are accepted but have no effect, and `next_page` is always `null`.
    /// Returns explicit per-workspace enablements only; for rules with
    /// `applies_to_all_workspaces` or a legacy single `workspace_id`, check those
    /// fields on the rule itself.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
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
        public func list<R: Sendable>(_ federationRuleID: String, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<FederationRuleWorkspace>>) async throws -> R) async throws -> R {
            let response = try await resource._list(federationRuleID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Enable a federation rule for a workspace.
    ///
    /// Idempotent; re-enabling returns the existing enablement. The rule and workspace
    /// must both belong to your organization. Membership of the rule's target service
    /// account in this workspace is not checked at enablement: token exchange into this
    /// workspace is rejected unless the target is a member (it is implicitly a member
    /// of the default workspace). Archived rules are rejected with 400. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ federationRuleID: String, workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FederationRuleWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._add(federationRuleID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Disable a federation rule for a workspace.
    ///
    /// Idempotent; succeeds even if the enablement was already removed. OAuth callers
    /// may only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   workspace_id: ID of the workspace to disable for.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ workspaceID: String, federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationFederationRulesWorkspaceRemoveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._remove(workspaceID, federationRuleID: federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
