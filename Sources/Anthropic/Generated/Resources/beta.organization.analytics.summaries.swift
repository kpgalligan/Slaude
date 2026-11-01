// Transformed from `anthropic.resources.beta.organization.analytics.summaries` (summaries.py).

import Foundation

public struct BetaOrganizationAnalyticsSummariesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get organization-wide activity summaries for a date range.
    ///
    /// Returns one entry per day from `starting_date` (inclusive) to `ending_date`
    /// (exclusive) in `data`, the same `data` / `next_page` envelope as the other
    /// analytics list endpoints; the series is currently returned in full, so
    /// `next_page` is always null. Data is typically available with a 1-day lag and may
    /// be revised by a few percent over the following days: when `ending_date` is
    /// omitted it defaults to the most recent available day + 1, so the last entry
    /// covers the most recent available day. The series can be scoped to an RBAC group
    /// via `filter[]=rbac_group_id:{id}`. Available to organizations on a Claude
    /// Enterprise plan. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of the date range (inclusive). Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive). Data is
    ///       typically available with a 1-day lag, so this can be at most today — which is
    ///       also the default when omitted, making the last entry cover the most recent
    ///       available day. Data may be revised by a few percent over the following days. The
    ///       range may span at most 366 days.
    ///
    ///   filter: Filters as `dimension:value`. Only `rbac_group_id` is supported (e.g.
    ///       `filter[]=rbac_group_id:{id}`); repeat the param to OR across groups. Scopes the
    ///       whole day series to members of the matching group(s), re-aggregated from
    ///       member-level activity — org-wide seat/invite fields and the adoption rates
    ///       derived from them are null on scoped rows. `rbac_group_id` accepts the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       UTC day (time-of-usage attribution). At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100). The day series (at most 366
    ///       entries) is currently returned in full in a single page, so `limit` does not yet
    ///       shorten it.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. `next_page` is
    ///       currently always null, so there is never a cursor to send.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(startingDate: SummaryListParams.StartingDate, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaAnalyticsSingleDayActivitySummary> {
        try await _list(startingDate: startingDate, endingDate: endingDate, filter: filter, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(startingDate: SummaryListParams.StartingDate, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaAnalyticsSingleDayActivitySummary>> {
        var query = ParamsBuilder()
        try query.set("starting_date", startingDate)
        try query.set("ending_date", endingDate)
        try query.set("filter", filter)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/analytics/summaries", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.analytics.summaries.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaAnalyticsSingleDayActivitySummary>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsSummariesResource

    /// Get organization-wide activity summaries for a date range.
    ///
    /// Returns one entry per day from `starting_date` (inclusive) to `ending_date`
    /// (exclusive) in `data`, the same `data` / `next_page` envelope as the other
    /// analytics list endpoints; the series is currently returned in full, so
    /// `next_page` is always null. Data is typically available with a 1-day lag and may
    /// be revised by a few percent over the following days: when `ending_date` is
    /// omitted it defaults to the most recent available day + 1, so the last entry
    /// covers the most recent available day. The series can be scoped to an RBAC group
    /// via `filter[]=rbac_group_id:{id}`. Available to organizations on a Claude
    /// Enterprise plan. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of the date range (inclusive). Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive). Data is
    ///       typically available with a 1-day lag, so this can be at most today — which is
    ///       also the default when omitted, making the last entry cover the most recent
    ///       available day. Data may be revised by a few percent over the following days. The
    ///       range may span at most 366 days.
    ///
    ///   filter: Filters as `dimension:value`. Only `rbac_group_id` is supported (e.g.
    ///       `filter[]=rbac_group_id:{id}`); repeat the param to OR across groups. Scopes the
    ///       whole day series to members of the matching group(s), re-aggregated from
    ///       member-level activity — org-wide seat/invite fields and the adoption rates
    ///       derived from them are null on scoped rows. `rbac_group_id` accepts the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       UTC day (time-of-usage attribution). At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100). The day series (at most 366
    ///       entries) is currently returned in full in a single page, so `limit` does not yet
    ///       shorten it.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. `next_page` is
    ///       currently always null, so there is never a cursor to send.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(startingDate: SummaryListParams.StartingDate, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaAnalyticsSingleDayActivitySummary>> {
            try await resource._list(startingDate: startingDate, endingDate: endingDate, filter: filter, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsSummariesResource

    /// Get organization-wide activity summaries for a date range.
    ///
    /// Returns one entry per day from `starting_date` (inclusive) to `ending_date`
    /// (exclusive) in `data`, the same `data` / `next_page` envelope as the other
    /// analytics list endpoints; the series is currently returned in full, so
    /// `next_page` is always null. Data is typically available with a 1-day lag and may
    /// be revised by a few percent over the following days: when `ending_date` is
    /// omitted it defaults to the most recent available day + 1, so the last entry
    /// covers the most recent available day. The series can be scoped to an RBAC group
    /// via `filter[]=rbac_group_id:{id}`. Available to organizations on a Claude
    /// Enterprise plan. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of the date range (inclusive). Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive). Data is
    ///       typically available with a 1-day lag, so this can be at most today — which is
    ///       also the default when omitted, making the last entry cover the most recent
    ///       available day. Data may be revised by a few percent over the following days. The
    ///       range may span at most 366 days.
    ///
    ///   filter: Filters as `dimension:value`. Only `rbac_group_id` is supported (e.g.
    ///       `filter[]=rbac_group_id:{id}`); repeat the param to OR across groups. Scopes the
    ///       whole day series to members of the matching group(s), re-aggregated from
    ///       member-level activity — org-wide seat/invite fields and the adoption rates
    ///       derived from them are null on scoped rows. `rbac_group_id` accepts the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       UTC day (time-of-usage attribution). At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100). The day series (at most 366
    ///       entries) is currently returned in full in a single page, so `limit` does not yet
    ///       shorten it.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. `next_page` is
    ///       currently always null, so there is never a cursor to send.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(startingDate: SummaryListParams.StartingDate, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaAnalyticsSingleDayActivitySummary>>) async throws -> R) async throws -> R {
            let response = try await resource._list(startingDate: startingDate, endingDate: endingDate, filter: filter, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
