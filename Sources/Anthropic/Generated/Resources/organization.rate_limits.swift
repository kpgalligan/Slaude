// Transformed from `anthropic.resources.organization.rate_limits` (rate_limits.py).

import Foundation

public struct OrganizationRateLimitsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List Messages API rate limits for your organization.
    ///
    /// Each entry corresponds to one rate-limit group (either a model family or an
    /// API-surface category such as the Message Batches API or the web search tool) and
    /// contains the set of limiter values that apply to it.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   group_type: Filter by group type.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
    ///
    ///   model: Filter to the single entry containing this model. Accepts full model names and
    ///       aliases. Returns 404 if the model is not found or has no rate limits for this
    ///       organization.
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
    public func list(groupType: RateLimitListParams.GroupType?? = nil, limit: Int?? = nil, model: String?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<OrganizationRateLimit> {
        try await _list(groupType: groupType, limit: limit, model: model, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(groupType: RateLimitListParams.GroupType?? = nil, limit: Int?? = nil, model: String?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<OrganizationRateLimit>> {
        var query = ParamsBuilder()
        try query.set("group_type", groupType)
        try query.set("limit", limit)
        try query.set("model", model)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/rate_limits", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.rate_limits.list")
        return try await client.requestPageResponse(PageCursor<OrganizationRateLimit>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationRateLimitsResource

    /// List Messages API rate limits for your organization.
    ///
    /// Each entry corresponds to one rate-limit group (either a model family or an
    /// API-surface category such as the Message Batches API or the web search tool) and
    /// contains the set of limiter values that apply to it.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   group_type: Filter by group type.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
    ///
    ///   model: Filter to the single entry containing this model. Accepts full model names and
    ///       aliases. Returns 404 if the model is not found or has no rate limits for this
    ///       organization.
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
        public func list(groupType: RateLimitListParams.GroupType?? = nil, limit: Int?? = nil, model: String?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<OrganizationRateLimit>> {
            try await resource._list(groupType: groupType, limit: limit, model: model, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationRateLimitsResource

    /// List Messages API rate limits for your organization.
    ///
    /// Each entry corresponds to one rate-limit group (either a model family or an
    /// API-surface category such as the Message Batches API or the web search tool) and
    /// contains the set of limiter values that apply to it.
    ///
    /// When `limit` is omitted, every matching entry is returned in a single page; when
    /// `limit` truncates the result, follow `next_page` to fetch the remaining entries.
    ///
    /// Args:
    ///   group_type: Filter by group type.
    ///
    ///   limit: Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    ///       When omitted, every remaining entry is returned in a single page and `next_page`
    ///       is `null`.
    ///
    ///   model: Filter to the single entry containing this model. Accepts full model names and
    ///       aliases. Returns 404 if the model is not found or has no rate limits for this
    ///       organization.
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
        public func list<R: Sendable>(groupType: RateLimitListParams.GroupType?? = nil, limit: Int?? = nil, model: String?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<OrganizationRateLimit>>) async throws -> R) async throws -> R {
            let response = try await resource._list(groupType: groupType, limit: limit, model: model, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
