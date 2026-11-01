// Transformed from `anthropic.resources.beta.organization.spend_limits.effective` (effective.py).

import Foundation

public struct BetaOrganizationSpendLimitsEffectiveResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List each member's effective spend limit and period-to-date spend.
    ///
    /// Returns one row per (member, period) the member resolves a spend limit for, with
    /// the `source` scope the spend limit was inherited from. Paginates by member, so a
    /// member's periods never split across pages. Supported for Claude Enterprise
    /// organizations only, not for Claude Console organizations.
    ///
    /// Args:
    ///   limit: Maximum number of members per page. A member's period rows never split across
    ///       pages, so a page may carry more rows than this. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   period: Restrict the report to these limit periods. Omit to return one row per period
    ///       each member resolves a spend limit for.
    ///
    ///   user_ids: Restrict the report to these members, by tagged user ID (`user_...`). At most
    ///       100 entries.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(limit: Int? = nil, page: String?? = nil, period: [EffectiveListParams.Period]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaSpendSummary> {
        try await _list(limit: limit, page: page, period: period, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, period: [EffectiveListParams.Period]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaSpendSummary>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("period", period)
        try query.set("user_ids", userIDs)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/spend_limits/effective", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.effective.list", spanRoute: "/v1/organizations/spend_limits/effective", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaSpendSummary>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsEffectiveResource

    /// List each member's effective spend limit and period-to-date spend.
    ///
    /// Returns one row per (member, period) the member resolves a spend limit for, with
    /// the `source` scope the spend limit was inherited from. Paginates by member, so a
    /// member's periods never split across pages. Supported for Claude Enterprise
    /// organizations only, not for Claude Console organizations.
    ///
    /// Args:
    ///   limit: Maximum number of members per page. A member's period rows never split across
    ///       pages, so a page may carry more rows than this. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   period: Restrict the report to these limit periods. Omit to return one row per period
    ///       each member resolves a spend limit for.
    ///
    ///   user_ids: Restrict the report to these members, by tagged user ID (`user_...`). At most
    ///       100 entries.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(limit: Int? = nil, page: String?? = nil, period: [EffectiveListParams.Period]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaSpendSummary>> {
            try await resource._list(limit: limit, page: page, period: period, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsEffectiveResource

    /// List each member's effective spend limit and period-to-date spend.
    ///
    /// Returns one row per (member, period) the member resolves a spend limit for, with
    /// the `source` scope the spend limit was inherited from. Paginates by member, so a
    /// member's periods never split across pages. Supported for Claude Enterprise
    /// organizations only, not for Claude Console organizations.
    ///
    /// Args:
    ///   limit: Maximum number of members per page. A member's period rows never split across
    ///       pages, so a page may carry more rows than this. Defaults to `20`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   period: Restrict the report to these limit periods. Omit to return one row per period
    ///       each member resolves a spend limit for.
    ///
    ///   user_ids: Restrict the report to these members, by tagged user ID (`user_...`). At most
    ///       100 entries.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, period: [EffectiveListParams.Period]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaSpendSummary>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, period: period, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
