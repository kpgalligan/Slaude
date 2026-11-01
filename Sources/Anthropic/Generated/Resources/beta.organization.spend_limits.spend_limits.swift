// Transformed from `anthropic.resources.beta.organization.spend_limits.spend_limits` (spend_limits.py).

import Foundation

public struct BetaOrganizationSpendLimitsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var effective: BetaOrganizationSpendLimitsEffectiveResource { BetaOrganizationSpendLimitsEffectiveResource(client: client) }

    public var increaseRequests: BetaOrganizationSpendLimitsIncreaseRequestsResource { BetaOrganizationSpendLimitsIncreaseRequestsResource(client: client) }

    /// Retrieve a spend limit by ID.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSpendLimit {
        try await _retrieve(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSpendLimit> {
        try requireNonEmpty(spendLimitID, "spend_limit_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/spend_limits/{spend_limit_id}", ["spend_limit_id": spendLimitID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.retrieve")
        return try await client.requestResponse(BetaSpendLimit.self, options, stream: _mode == .stream)
    }

    /// List the organization's spend limits.
    ///
    /// A Claude Console organization's limits, including any read-only `usage_tier`
    /// limit, come newest first. Listing them is in an early access preview. To request
    /// access, contact your Anthropic account team. A Claude Enterprise organization's
    /// limits are grouped by scope type, in the order `organization`, `seat_tier`,
    /// `rbac_group`, `organization_service`, `user`; within a type they come in a fixed
    /// order that is not creation order.
    ///
    /// Args:
    ///   limit: Maximum number of limits per page. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   scope_type: Return only limits with these scope types. Omit for all. A scope type that
    ///       doesn't apply to the organization gets a 400 error.
    ///
    ///   workspace_id: Return only the limits whose `scope.workspace_id` is this workspace
    ///       (`wrkspc_...`). Claude Console organizations only; other organizations get a 400
    ///       error.
    ///
    ///   betas: This endpoint is in beta: requests must send `spend-limit-reads-2026-09-26` in
    ///       this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(limit: Int? = nil, page: String?? = nil, scopeType: [SpendLimitListParams.ScopeType]?? = nil, workspaceID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaSpendLimit> {
        try await _list(limit: limit, page: page, scopeType: scopeType, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, scopeType: [SpendLimitListParams.ScopeType]?? = nil, workspaceID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaSpendLimit>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("scope_type", scopeType)
        try query.set("workspace_id", workspaceID)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/spend_limits", query: query, headers: mergeHeaderLayers(["anthropic-beta": "spend-limit-reads-2026-09-26"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["spend-limit-reads-2026-09-26"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.list")
        return try await client.requestPageResponse(PageCursor<BetaSpendLimit>.self, options, stream: _mode == .stream)
    }

    /// Delete a spend limit.
    ///
    /// For a Claude Enterprise organization, this deletes a per-user override, and the
    /// member falls back to any inherited spend limit at that period. Its seat-tier,
    /// group, and organization-level rows cannot be deleted via this endpoint. A Claude
    /// Console organization deletes its organization and workspace limits, but not its
    /// `usage_tier` limit. Deleting organization and workspace limits through the API
    /// is in an early access preview.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func delete(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> SpendLimitDeleteResponse {
        try await _delete(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<SpendLimitDeleteResponse> {
        try requireNonEmpty(spendLimitID, "spend_limit_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/spend_limits/{spend_limit_id}", ["spend_limit_id": spendLimitID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.delete")
        return try await client.requestResponse(SpendLimitDeleteResponse.self, options, stream: _mode == .stream)
    }

    /// Set a spend limit.
    ///
    /// Upsert keyed on (scope, period): setting a limit that already exists overwrites
    /// it in place. A Claude Enterprise organization sets `user` limits. Its seat-tier,
    /// group, and organization-level defaults are configured in claude.ai. A Claude
    /// Console organization sets `organization` and `workspace` limits, which are
    /// monthly and always carry an amount. Setting those limits is in an early access
    /// preview. To request access, contact your Anthropic account team.
    ///
    /// Args:
    ///   amount: Limit amount as a non-negative integer decimal string in the minor unit of the
    ///       organization's billing currency (cents for USD): "50000" is $500.00. `null` sets
    ///       an explicit no-limit override for this scope and `period` only — each period
    ///       resolves independently, so caps for other periods still apply.
    ///
    ///   scope: What the limit applies to. Claude Enterprise organizations set `user` limits.
    ///       Claude Console organizations set `organization` and `workspace` limits. Any
    ///       other combination returns 400. Setting `organization` and `workspace` limits
    ///       through the API is in an early access preview. To request access, contact your
    ///       Anthropic account team.
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
    public func set(amount: String?, scope: SpendLimitSetParams.Scope, period: BetaSpendLimitPeriod? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSpendLimit {
        try await _set(amount: amount, scope: scope, period: period, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _set(amount: String?, scope: SpendLimitSetParams.Scope, period: BetaSpendLimitPeriod? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSpendLimit> {
        var body = ParamsBuilder()
        try body.set("amount", amount)
        try body.set("scope", scope)
        try body.set("period", period)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/spend_limits", body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.set")
        return try await client.requestResponse(BetaSpendLimit.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsResource

        public var effective: BetaOrganizationSpendLimitsEffectiveResource.WithRawResponse { resource.effective.withRawResponse }

        public var increaseRequests: BetaOrganizationSpendLimitsIncreaseRequestsResource.WithRawResponse { resource.increaseRequests.withRawResponse }

    /// Retrieve a spend limit by ID.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSpendLimit> {
            try await resource._retrieve(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's spend limits.
    ///
    /// A Claude Console organization's limits, including any read-only `usage_tier`
    /// limit, come newest first. Listing them is in an early access preview. To request
    /// access, contact your Anthropic account team. A Claude Enterprise organization's
    /// limits are grouped by scope type, in the order `organization`, `seat_tier`,
    /// `rbac_group`, `organization_service`, `user`; within a type they come in a fixed
    /// order that is not creation order.
    ///
    /// Args:
    ///   limit: Maximum number of limits per page. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   scope_type: Return only limits with these scope types. Omit for all. A scope type that
    ///       doesn't apply to the organization gets a 400 error.
    ///
    ///   workspace_id: Return only the limits whose `scope.workspace_id` is this workspace
    ///       (`wrkspc_...`). Claude Console organizations only; other organizations get a 400
    ///       error.
    ///
    ///   betas: This endpoint is in beta: requests must send `spend-limit-reads-2026-09-26` in
    ///       this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(limit: Int? = nil, page: String?? = nil, scopeType: [SpendLimitListParams.ScopeType]?? = nil, workspaceID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaSpendLimit>> {
            try await resource._list(limit: limit, page: page, scopeType: scopeType, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a spend limit.
    ///
    /// For a Claude Enterprise organization, this deletes a per-user override, and the
    /// member falls back to any inherited spend limit at that period. Its seat-tier,
    /// group, and organization-level rows cannot be deleted via this endpoint. A Claude
    /// Console organization deletes its organization and workspace limits, but not its
    /// `usage_tier` limit. Deleting organization and workspace limits through the API
    /// is in an early access preview.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<SpendLimitDeleteResponse> {
            try await resource._delete(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Set a spend limit.
    ///
    /// Upsert keyed on (scope, period): setting a limit that already exists overwrites
    /// it in place. A Claude Enterprise organization sets `user` limits. Its seat-tier,
    /// group, and organization-level defaults are configured in claude.ai. A Claude
    /// Console organization sets `organization` and `workspace` limits, which are
    /// monthly and always carry an amount. Setting those limits is in an early access
    /// preview. To request access, contact your Anthropic account team.
    ///
    /// Args:
    ///   amount: Limit amount as a non-negative integer decimal string in the minor unit of the
    ///       organization's billing currency (cents for USD): "50000" is $500.00. `null` sets
    ///       an explicit no-limit override for this scope and `period` only — each period
    ///       resolves independently, so caps for other periods still apply.
    ///
    ///   scope: What the limit applies to. Claude Enterprise organizations set `user` limits.
    ///       Claude Console organizations set `organization` and `workspace` limits. Any
    ///       other combination returns 400. Setting `organization` and `workspace` limits
    ///       through the API is in an early access preview. To request access, contact your
    ///       Anthropic account team.
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
        public func set(amount: String?, scope: SpendLimitSetParams.Scope, period: BetaSpendLimitPeriod? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSpendLimit> {
            try await resource._set(amount: amount, scope: scope, period: period, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsResource

        public var effective: BetaOrganizationSpendLimitsEffectiveResource.WithStreamingResponse { resource.effective.withStreamingResponse }

        public var increaseRequests: BetaOrganizationSpendLimitsIncreaseRequestsResource.WithStreamingResponse { resource.increaseRequests.withStreamingResponse }

    /// Retrieve a spend limit by ID.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSpendLimit>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's spend limits.
    ///
    /// A Claude Console organization's limits, including any read-only `usage_tier`
    /// limit, come newest first. Listing them is in an early access preview. To request
    /// access, contact your Anthropic account team. A Claude Enterprise organization's
    /// limits are grouped by scope type, in the order `organization`, `seat_tier`,
    /// `rbac_group`, `organization_service`, `user`; within a type they come in a fixed
    /// order that is not creation order.
    ///
    /// Args:
    ///   limit: Maximum number of limits per page. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   scope_type: Return only limits with these scope types. Omit for all. A scope type that
    ///       doesn't apply to the organization gets a 400 error.
    ///
    ///   workspace_id: Return only the limits whose `scope.workspace_id` is this workspace
    ///       (`wrkspc_...`). Claude Console organizations only; other organizations get a 400
    ///       error.
    ///
    ///   betas: This endpoint is in beta: requests must send `spend-limit-reads-2026-09-26` in
    ///       this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, scopeType: [SpendLimitListParams.ScopeType]?? = nil, workspaceID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaSpendLimit>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, scopeType: scopeType, workspaceID: workspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a spend limit.
    ///
    /// For a Claude Enterprise organization, this deletes a per-user override, and the
    /// member falls back to any inherited spend limit at that period. Its seat-tier,
    /// group, and organization-level rows cannot be deleted via this endpoint. A Claude
    /// Console organization deletes its organization and workspace limits, but not its
    /// `usage_tier` limit. Deleting organization and workspace limits through the API
    /// is in an early access preview.
    ///
    /// Args:
    ///   spend_limit_id: ID of the Spend Limit.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete<R: Sendable>(_ spendLimitID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<SpendLimitDeleteResponse>) async throws -> R) async throws -> R {
            let response = try await resource._delete(spendLimitID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Set a spend limit.
    ///
    /// Upsert keyed on (scope, period): setting a limit that already exists overwrites
    /// it in place. A Claude Enterprise organization sets `user` limits. Its seat-tier,
    /// group, and organization-level defaults are configured in claude.ai. A Claude
    /// Console organization sets `organization` and `workspace` limits, which are
    /// monthly and always carry an amount. Setting those limits is in an early access
    /// preview. To request access, contact your Anthropic account team.
    ///
    /// Args:
    ///   amount: Limit amount as a non-negative integer decimal string in the minor unit of the
    ///       organization's billing currency (cents for USD): "50000" is $500.00. `null` sets
    ///       an explicit no-limit override for this scope and `period` only — each period
    ///       resolves independently, so caps for other periods still apply.
    ///
    ///   scope: What the limit applies to. Claude Enterprise organizations set `user` limits.
    ///       Claude Console organizations set `organization` and `workspace` limits. Any
    ///       other combination returns 400. Setting `organization` and `workspace` limits
    ///       through the API is in an early access preview. To request access, contact your
    ///       Anthropic account team.
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
        public func set<R: Sendable>(amount: String?, scope: SpendLimitSetParams.Scope, period: BetaSpendLimitPeriod? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSpendLimit>) async throws -> R) async throws -> R {
            let response = try await resource._set(amount: amount, scope: scope, period: period, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
