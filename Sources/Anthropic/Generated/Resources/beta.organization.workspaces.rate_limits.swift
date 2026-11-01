// Transformed from `anthropic.resources.beta.organization.workspaces.rate_limits` (rate_limits.py).

import Foundation

public struct BetaOrganizationWorkspacesRateLimitsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Set or clear rate-limit overrides for one rate-limit group in a workspace.
    ///
    /// Only the limiter types named in `limits` change: an integer `value` sets that
    /// type's override and `null` clears it. Types not named keep their current value.
    /// A value above the organization's own limit is stored, but the organization limit
    /// still applies, so the lower of the two is enforced.
    ///
    /// Returns the targeted group's entry with this request applied, in the shape
    /// `GET /v1/organizations/workspaces/{workspace_id}/rate_limits` returns. Changes
    /// take effect within about an hour.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   rate_limit_id: The `id` of the organization's rate-limit entry to set overrides for.
    ///
    ///   limits: Limits to set or clear. Unspecified limit types are unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ rateLimitID: String, workspaceID: String, limits: [BetaWorkspaceRateLimitUpdateValueParam], extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaWorkspaceRateLimit {
        try await _update(rateLimitID, workspaceID: workspaceID, limits: limits, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ rateLimitID: String, workspaceID: String, limits: [BetaWorkspaceRateLimitUpdateValueParam], extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaWorkspaceRateLimit> {
        try requireNonEmpty(workspaceID, "workspace_id")
        try requireNonEmpty(rateLimitID, "rate_limit_id")
        var body = ParamsBuilder()
        try body.set("limits", limits)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/rate_limits/{rate_limit_id}", ["workspace_id": workspaceID, "rate_limit_id": rateLimitID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.rate_limits.update")
        return try await client.requestResponse(BetaWorkspaceRateLimit.self, options, stream: _mode == .stream)
    }

    /// List a workspace's rate limits.
    ///
    /// By default, returns only the groups and limiter types that have a
    /// workspace-level override. With `include_inherited=true`, returns every group
    /// with organization-level limits the workspace can see, listing for each the
    /// values it inherits from the organization as well as its own overrides. Each
    /// value's `source` says which it is.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   group_type: Filter by group type.
    ///
    ///   include_inherited: Also list the limiter values the workspace inherits from the organization,
    ///       including groups with no workspace-level override.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
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
    public func list(_ workspaceID: String, groupType: BetaOrganizationRateLimitListParams.GroupType?? = nil, includeInherited: Bool? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaWorkspaceRateLimit> {
        try await _list(workspaceID, groupType: groupType, includeInherited: includeInherited, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ workspaceID: String, groupType: BetaOrganizationRateLimitListParams.GroupType?? = nil, includeInherited: Bool? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaWorkspaceRateLimit>> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var query = ParamsBuilder()
        try query.set("group_type", groupType)
        try query.set("include_inherited", includeInherited)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/rate_limits", ["workspace_id": workspaceID]), query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.rate_limits.list")
        return try await client.requestPageResponse(PageCursor<BetaWorkspaceRateLimit>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationWorkspacesRateLimitsResource

    /// Set or clear rate-limit overrides for one rate-limit group in a workspace.
    ///
    /// Only the limiter types named in `limits` change: an integer `value` sets that
    /// type's override and `null` clears it. Types not named keep their current value.
    /// A value above the organization's own limit is stored, but the organization limit
    /// still applies, so the lower of the two is enforced.
    ///
    /// Returns the targeted group's entry with this request applied, in the shape
    /// `GET /v1/organizations/workspaces/{workspace_id}/rate_limits` returns. Changes
    /// take effect within about an hour.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   rate_limit_id: The `id` of the organization's rate-limit entry to set overrides for.
    ///
    ///   limits: Limits to set or clear. Unspecified limit types are unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ rateLimitID: String, workspaceID: String, limits: [BetaWorkspaceRateLimitUpdateValueParam], extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaWorkspaceRateLimit> {
            try await resource._update(rateLimitID, workspaceID: workspaceID, limits: limits, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List a workspace's rate limits.
    ///
    /// By default, returns only the groups and limiter types that have a
    /// workspace-level override. With `include_inherited=true`, returns every group
    /// with organization-level limits the workspace can see, listing for each the
    /// values it inherits from the organization as well as its own overrides. Each
    /// value's `source` says which it is.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   group_type: Filter by group type.
    ///
    ///   include_inherited: Also list the limiter values the workspace inherits from the organization,
    ///       including groups with no workspace-level override.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
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
        public func list(_ workspaceID: String, groupType: BetaOrganizationRateLimitListParams.GroupType?? = nil, includeInherited: Bool? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaWorkspaceRateLimit>> {
            try await resource._list(workspaceID, groupType: groupType, includeInherited: includeInherited, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationWorkspacesRateLimitsResource

    /// Set or clear rate-limit overrides for one rate-limit group in a workspace.
    ///
    /// Only the limiter types named in `limits` change: an integer `value` sets that
    /// type's override and `null` clears it. Types not named keep their current value.
    /// A value above the organization's own limit is stored, but the organization limit
    /// still applies, so the lower of the two is enforced.
    ///
    /// Returns the targeted group's entry with this request applied, in the shape
    /// `GET /v1/organizations/workspaces/{workspace_id}/rate_limits` returns. Changes
    /// take effect within about an hour.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   rate_limit_id: The `id` of the organization's rate-limit entry to set overrides for.
    ///
    ///   limits: Limits to set or clear. Unspecified limit types are unchanged.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ rateLimitID: String, workspaceID: String, limits: [BetaWorkspaceRateLimitUpdateValueParam], extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaWorkspaceRateLimit>) async throws -> R) async throws -> R {
            let response = try await resource._update(rateLimitID, workspaceID: workspaceID, limits: limits, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List a workspace's rate limits.
    ///
    /// By default, returns only the groups and limiter types that have a
    /// workspace-level override. With `include_inherited=true`, returns every group
    /// with organization-level limits the workspace can see, listing for each the
    /// values it inherits from the organization as well as its own overrides. Each
    /// value's `source` says which it is.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   workspace_id: The ID of the workspace.
    ///
    ///   group_type: Filter by group type.
    ///
    ///   include_inherited: Also list the limiter values the workspace inherits from the organization,
    ///       including groups with no workspace-level override.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
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
        public func list<R: Sendable>(_ workspaceID: String, groupType: BetaOrganizationRateLimitListParams.GroupType?? = nil, includeInherited: Bool? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaWorkspaceRateLimit>>) async throws -> R) async throws -> R {
            let response = try await resource._list(workspaceID, groupType: groupType, includeInherited: includeInherited, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
