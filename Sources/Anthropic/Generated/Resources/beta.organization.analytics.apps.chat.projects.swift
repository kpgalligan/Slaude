// Transformed from `anthropic.resources.beta.organization.analytics.apps.chat.projects` (projects.py).

import Foundation

public struct BetaOrganizationAnalyticsAppsChatProjectsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get per-project activity for a given day, with cursor-based pagination.
    ///
    /// Returns activity metrics for each project in the organization, sorted by project
    /// ID. Use `group_by[]` to break projects out per member or per RBAC group, and
    /// `filter[]` to scope results; the parameter descriptions list the supported
    /// dimensions. Available to organizations on a Claude Enterprise plan. Requires an
    /// API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get project activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive); only valid
    ///       with `starting_date`. Data is typically available with a 1-day lag (varies by
    ///       query; the error for a too-recent date names the latest available day), so this
    ///       can be at most today — which is also the default when omitted, resolved once
    ///       when the first page is served and reused for the rest of the pagination
    ///       sequence. At most 366 days after `starting_date`.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `project_id`, `rbac_group_id`, `user_id`. Value
    ///       forms: `project_id` takes a tagged project id (`claude_proj_...`);
    ///       `rbac_group_id` takes the tagged id (`rbac_group_...`, as emitted in responses
    ///       and by the spend-limits API) or a bare group UUID, and matches users who held
    ///       the group at any point during each covered UTC day (time-of-usage attribution);
    ///       `user_id` takes a tagged user id (`user_...`), as emitted in responses. An
    ///       unsupported dimension returns 400. At most 100 entries.
    ///
    ///   group_by: Dimensions to break results out by (e.g. `group_by[]=user_id`). Supported on
    ///       this endpoint: `rbac_group_id`, `user_id`. Grouped rows carry the requested
    ///       dimension values as additional fields and paginate like ungrouped responses via
    ///       `next_page`; an unsupported dimension returns 400. `rbac_group_id` attributes a
    ///       user to every group they held at any point during each covered UTC day, so
    ///       grouped rows are not an exclusive partition and can sum above org-level totals.
    ///       At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100).
    ///
    ///   order: Sort direction: `asc` or `desc`. Defaults to `asc` for the endpoint's sort
    ///       column and to `desc` when `order_by` names a metric (a top-N ranking). Applies
    ///       to `order_by`, or to the endpoint's default sort field when `order_by` is
    ///       omitted.
    ///
    ///   order_by: Sort field. Restricted to the endpoint's sort column plus its rankable metrics
    ///       (metrics default to descending; a few metrics rank in date-range mode only, per
    ///       the endpoint's documented orderable set).
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of a date range (inclusive). Enables rollup
    ///       mode: one row per entity aggregated over the whole range — addable counters are
    ///       summed across days, and a distinct count is never summed where summing could
    ///       double-count (a field's range value is recomputed exactly over the window,
    ///       approximate via HLL with typical error under 2%, null, or — for the
    ///       creation-event counts, whose per-day values cannot overlap — a per-day sum that
    ///       is itself exact; each field's own description says which). Use either `date` or
    ///       `starting_date`, not both. Data is typically available with a 1-day lag (varies
    ///       by query; the error for a too-recent date names the latest available day) and
    ///       may be revised by a few percent over the following days. No earlier than
    ///       2026-01-01.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(date: ListDate?? = nil, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, groupBy: [ProjectListParams.GroupBy]?? = nil, limit: Int?? = nil, order: ProjectListParams.Order?? = nil, orderBy: String?? = nil, page: String?? = nil, startingDate: ListStartingDate?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaAnalyticsProjectActivity> {
        try await _list(date: date, endingDate: endingDate, filter: filter, groupBy: groupBy, limit: limit, order: order, orderBy: orderBy, page: page, startingDate: startingDate, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(date: ListDate?? = nil, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, groupBy: [ProjectListParams.GroupBy]?? = nil, limit: Int?? = nil, order: ProjectListParams.Order?? = nil, orderBy: String?? = nil, page: String?? = nil, startingDate: ListStartingDate?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaAnalyticsProjectActivity>> {
        var query = ParamsBuilder()
        try query.set("date", date)
        try query.set("ending_date", endingDate)
        try query.set("filter", filter)
        try query.set("group_by", groupBy)
        try query.set("limit", limit)
        try query.set("order", order)
        try query.set("order_by", orderBy)
        try query.set("page", page)
        try query.set("starting_date", startingDate)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/analytics/apps/chat/projects", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.analytics.apps.chat.projects.list", spanRoute: "/v1/organizations/analytics/apps/chat/projects", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaAnalyticsProjectActivity>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsChatProjectsResource

    /// Get per-project activity for a given day, with cursor-based pagination.
    ///
    /// Returns activity metrics for each project in the organization, sorted by project
    /// ID. Use `group_by[]` to break projects out per member or per RBAC group, and
    /// `filter[]` to scope results; the parameter descriptions list the supported
    /// dimensions. Available to organizations on a Claude Enterprise plan. Requires an
    /// API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get project activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive); only valid
    ///       with `starting_date`. Data is typically available with a 1-day lag (varies by
    ///       query; the error for a too-recent date names the latest available day), so this
    ///       can be at most today — which is also the default when omitted, resolved once
    ///       when the first page is served and reused for the rest of the pagination
    ///       sequence. At most 366 days after `starting_date`.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `project_id`, `rbac_group_id`, `user_id`. Value
    ///       forms: `project_id` takes a tagged project id (`claude_proj_...`);
    ///       `rbac_group_id` takes the tagged id (`rbac_group_...`, as emitted in responses
    ///       and by the spend-limits API) or a bare group UUID, and matches users who held
    ///       the group at any point during each covered UTC day (time-of-usage attribution);
    ///       `user_id` takes a tagged user id (`user_...`), as emitted in responses. An
    ///       unsupported dimension returns 400. At most 100 entries.
    ///
    ///   group_by: Dimensions to break results out by (e.g. `group_by[]=user_id`). Supported on
    ///       this endpoint: `rbac_group_id`, `user_id`. Grouped rows carry the requested
    ///       dimension values as additional fields and paginate like ungrouped responses via
    ///       `next_page`; an unsupported dimension returns 400. `rbac_group_id` attributes a
    ///       user to every group they held at any point during each covered UTC day, so
    ///       grouped rows are not an exclusive partition and can sum above org-level totals.
    ///       At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100).
    ///
    ///   order: Sort direction: `asc` or `desc`. Defaults to `asc` for the endpoint's sort
    ///       column and to `desc` when `order_by` names a metric (a top-N ranking). Applies
    ///       to `order_by`, or to the endpoint's default sort field when `order_by` is
    ///       omitted.
    ///
    ///   order_by: Sort field. Restricted to the endpoint's sort column plus its rankable metrics
    ///       (metrics default to descending; a few metrics rank in date-range mode only, per
    ///       the endpoint's documented orderable set).
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of a date range (inclusive). Enables rollup
    ///       mode: one row per entity aggregated over the whole range — addable counters are
    ///       summed across days, and a distinct count is never summed where summing could
    ///       double-count (a field's range value is recomputed exactly over the window,
    ///       approximate via HLL with typical error under 2%, null, or — for the
    ///       creation-event counts, whose per-day values cannot overlap — a per-day sum that
    ///       is itself exact; each field's own description says which). Use either `date` or
    ///       `starting_date`, not both. Data is typically available with a 1-day lag (varies
    ///       by query; the error for a too-recent date names the latest available day) and
    ///       may be revised by a few percent over the following days. No earlier than
    ///       2026-01-01.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(date: ListDate?? = nil, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, groupBy: [ProjectListParams.GroupBy]?? = nil, limit: Int?? = nil, order: ProjectListParams.Order?? = nil, orderBy: String?? = nil, page: String?? = nil, startingDate: ListStartingDate?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaAnalyticsProjectActivity>> {
            try await resource._list(date: date, endingDate: endingDate, filter: filter, groupBy: groupBy, limit: limit, order: order, orderBy: orderBy, page: page, startingDate: startingDate, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsChatProjectsResource

    /// Get per-project activity for a given day, with cursor-based pagination.
    ///
    /// Returns activity metrics for each project in the organization, sorted by project
    /// ID. Use `group_by[]` to break projects out per member or per RBAC group, and
    /// `filter[]` to scope results; the parameter descriptions list the supported
    /// dimensions. Available to organizations on a Claude Enterprise plan. Requires an
    /// API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get project activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   ending_date: UTC date in YYYY-MM-DD format. End of the date range (exclusive); only valid
    ///       with `starting_date`. Data is typically available with a 1-day lag (varies by
    ///       query; the error for a too-recent date names the latest available day), so this
    ///       can be at most today — which is also the default when omitted, resolved once
    ///       when the first page is served and reused for the rest of the pagination
    ///       sequence. At most 366 days after `starting_date`.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `project_id`, `rbac_group_id`, `user_id`. Value
    ///       forms: `project_id` takes a tagged project id (`claude_proj_...`);
    ///       `rbac_group_id` takes the tagged id (`rbac_group_...`, as emitted in responses
    ///       and by the spend-limits API) or a bare group UUID, and matches users who held
    ///       the group at any point during each covered UTC day (time-of-usage attribution);
    ///       `user_id` takes a tagged user id (`user_...`), as emitted in responses. An
    ///       unsupported dimension returns 400. At most 100 entries.
    ///
    ///   group_by: Dimensions to break results out by (e.g. `group_by[]=user_id`). Supported on
    ///       this endpoint: `rbac_group_id`, `user_id`. Grouped rows carry the requested
    ///       dimension values as additional fields and paginate like ungrouped responses via
    ///       `next_page`; an unsupported dimension returns 400. `rbac_group_id` attributes a
    ///       user to every group they held at any point during each covered UTC day, so
    ///       grouped rows are not an exclusive partition and can sum above org-level totals.
    ///       At most 100 entries.
    ///
    ///   limit: Number of results per page (1-1000, default 100).
    ///
    ///   order: Sort direction: `asc` or `desc`. Defaults to `asc` for the endpoint's sort
    ///       column and to `desc` when `order_by` names a metric (a top-N ranking). Applies
    ///       to `order_by`, or to the endpoint's default sort field when `order_by` is
    ///       omitted.
    ///
    ///   order_by: Sort field. Restricted to the endpoint's sort column plus its rankable metrics
    ///       (metrics default to descending; a few metrics rank in date-range mode only, per
    ///       the endpoint's documented orderable set).
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   starting_date: UTC date in YYYY-MM-DD format. Start of a date range (inclusive). Enables rollup
    ///       mode: one row per entity aggregated over the whole range — addable counters are
    ///       summed across days, and a distinct count is never summed where summing could
    ///       double-count (a field's range value is recomputed exactly over the window,
    ///       approximate via HLL with typical error under 2%, null, or — for the
    ///       creation-event counts, whose per-day values cannot overlap — a per-day sum that
    ///       is itself exact; each field's own description says which). Use either `date` or
    ///       `starting_date`, not both. Data is typically available with a 1-day lag (varies
    ///       by query; the error for a too-recent date names the latest available day) and
    ///       may be revised by a few percent over the following days. No earlier than
    ///       2026-01-01.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(date: ListDate?? = nil, endingDate: SummaryListParams.EndingDate?? = nil, filter: [String]?? = nil, groupBy: [ProjectListParams.GroupBy]?? = nil, limit: Int?? = nil, order: ProjectListParams.Order?? = nil, orderBy: String?? = nil, page: String?? = nil, startingDate: ListStartingDate?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaAnalyticsProjectActivity>>) async throws -> R) async throws -> R {
            let response = try await resource._list(date: date, endingDate: endingDate, filter: filter, groupBy: groupBy, limit: limit, order: order, orderBy: orderBy, page: page, startingDate: startingDate, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }

    public indirect enum ListDate: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(ISODate)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? ISODate(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum ListStartingDate: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(ISODate)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? ISODate(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
