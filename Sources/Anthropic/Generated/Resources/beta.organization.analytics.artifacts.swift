// Transformed from `anthropic.resources.beta.organization.analytics.artifacts` (artifacts.py).

import Foundation

public struct BetaOrganizationAnalyticsArtifactsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get artifact-creation activity for a given day, broken out by MIME type.
    ///
    /// Returns the full (`artifact_type`, `is_shared`) cube for the organization;
    /// `next_page` is null except for grouped queries, which paginate. The cube can be
    /// broken out per product, per member, or per RBAC group via `group_by[]`, and
    /// scoped via `filter[]`. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get artifact activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `artifact_type`, `is_shared`, `product`,
    ///       `rbac_group_id`, `user_id`. Value forms: `artifact_type` is a canonical artifact
    ///       MIME type (e.g. `text/markdown`) or `other`; `is_shared` is `true` or `false`;
    ///       `product` is `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the
    ///       surfaces that create artifacts); `rbac_group_id` takes the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       covered UTC day (time-of-usage attribution); `user_id` takes a tagged user id
    ///       (`user_...`), as emitted in responses. An unsupported dimension returns 400. At
    ///       most 100 entries. `chat_cowork_unified` is accepted as a `product` value only on
    ///       deployments that offer Chat and Cowork unified.
    ///
    ///   group_by: Dimensions to break results out by: `product`, `user_id` and/or `rbac_group_id`.
    ///       The ungrouped artifact-type cube is finite and returned in full; grouped queries
    ///       multiply the cube and paginate via `next_page`. `product` takes the values
    ///       `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the surfaces that
    ///       create artifacts). `rbac_group_id` attributes a user to every group they held at
    ///       any point during the requested UTC day, so grouped rows are not an exclusive
    ///       partition. At most 100 entries.
    ///
    ///   limit: Maximum rows to return (1-1000, default 100). The ungrouped artifact-type cube
    ///       is finite and returned in full; `limit` is the page size only when `group_by[]`
    ///       multiplies the cube.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. Only valid with
    ///       `group_by[]` — the ungrouped cube is never paginated.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(date: ListDate, filter: [String]?? = nil, groupBy: [ArtifactListParams.GroupBy]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaAnalyticsArtifactActivity> {
        try await _list(date: date, filter: filter, groupBy: groupBy, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(date: ListDate, filter: [String]?? = nil, groupBy: [ArtifactListParams.GroupBy]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaAnalyticsArtifactActivity>> {
        var query = ParamsBuilder()
        try query.set("date", date)
        try query.set("filter", filter)
        try query.set("group_by", groupBy)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/analytics/artifacts", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.analytics.artifacts.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaAnalyticsArtifactActivity>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsArtifactsResource

    /// Get artifact-creation activity for a given day, broken out by MIME type.
    ///
    /// Returns the full (`artifact_type`, `is_shared`) cube for the organization;
    /// `next_page` is null except for grouped queries, which paginate. The cube can be
    /// broken out per product, per member, or per RBAC group via `group_by[]`, and
    /// scoped via `filter[]`. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get artifact activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `artifact_type`, `is_shared`, `product`,
    ///       `rbac_group_id`, `user_id`. Value forms: `artifact_type` is a canonical artifact
    ///       MIME type (e.g. `text/markdown`) or `other`; `is_shared` is `true` or `false`;
    ///       `product` is `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the
    ///       surfaces that create artifacts); `rbac_group_id` takes the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       covered UTC day (time-of-usage attribution); `user_id` takes a tagged user id
    ///       (`user_...`), as emitted in responses. An unsupported dimension returns 400. At
    ///       most 100 entries. `chat_cowork_unified` is accepted as a `product` value only on
    ///       deployments that offer Chat and Cowork unified.
    ///
    ///   group_by: Dimensions to break results out by: `product`, `user_id` and/or `rbac_group_id`.
    ///       The ungrouped artifact-type cube is finite and returned in full; grouped queries
    ///       multiply the cube and paginate via `next_page`. `product` takes the values
    ///       `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the surfaces that
    ///       create artifacts). `rbac_group_id` attributes a user to every group they held at
    ///       any point during the requested UTC day, so grouped rows are not an exclusive
    ///       partition. At most 100 entries.
    ///
    ///   limit: Maximum rows to return (1-1000, default 100). The ungrouped artifact-type cube
    ///       is finite and returned in full; `limit` is the page size only when `group_by[]`
    ///       multiplies the cube.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. Only valid with
    ///       `group_by[]` — the ungrouped cube is never paginated.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(date: ListDate, filter: [String]?? = nil, groupBy: [ArtifactListParams.GroupBy]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaAnalyticsArtifactActivity>> {
            try await resource._list(date: date, filter: filter, groupBy: groupBy, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsArtifactsResource

    /// Get artifact-creation activity for a given day, broken out by MIME type.
    ///
    /// Returns the full (`artifact_type`, `is_shared`) cube for the organization;
    /// `next_page` is null except for grouped queries, which paginate. The cube can be
    /// broken out per product, per member, or per RBAC group via `group_by[]`, and
    /// scoped via `filter[]`. Requires an API key with the `read:analytics` scope.
    ///
    /// Args:
    ///   date: UTC date in YYYY-MM-DD format. The day to get artifact activity for. Data is
    ///       typically available with a 1-day lag (varies by query; the error for a
    ///       too-recent date names the latest available day) and may be revised by a few
    ///       percent over the following days. No earlier than 2026-01-01.
    ///
    ///   filter: Filters as `dimension:value`, e.g. `filter[]=rbac_group_id:{id}`. Repeat the
    ///       param for OR within a dimension and across dimensions for AND. Supported
    ///       dimensions on this endpoint: `artifact_type`, `is_shared`, `product`,
    ///       `rbac_group_id`, `user_id`. Value forms: `artifact_type` is a canonical artifact
    ///       MIME type (e.g. `text/markdown`) or `other`; `is_shared` is `true` or `false`;
    ///       `product` is `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the
    ///       surfaces that create artifacts); `rbac_group_id` takes the tagged id
    ///       (`rbac_group_...`, as emitted in responses and by the spend-limits API) or a
    ///       bare group UUID, and matches users who held the group at any point during each
    ///       covered UTC day (time-of-usage attribution); `user_id` takes a tagged user id
    ///       (`user_...`), as emitted in responses. An unsupported dimension returns 400. At
    ///       most 100 entries. `chat_cowork_unified` is accepted as a `product` value only on
    ///       deployments that offer Chat and Cowork unified.
    ///
    ///   group_by: Dimensions to break results out by: `product`, `user_id` and/or `rbac_group_id`.
    ///       The ungrouped artifact-type cube is finite and returned in full; grouped queries
    ///       multiply the cube and paginate via `next_page`. `product` takes the values
    ///       `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the surfaces that
    ///       create artifacts). `rbac_group_id` attributes a user to every group they held at
    ///       any point during the requested UTC day, so grouped rows are not an exclusive
    ///       partition. At most 100 entries.
    ///
    ///   limit: Maximum rows to return (1-1000, default 100). The ungrouped artifact-type cube
    ///       is finite and returned in full; `limit` is the page size only when `group_by[]`
    ///       multiplies the cube.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field. Only valid with
    ///       `group_by[]` — the ungrouped cube is never paginated.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(date: ListDate, filter: [String]?? = nil, groupBy: [ArtifactListParams.GroupBy]?? = nil, limit: Int?? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaAnalyticsArtifactActivity>>) async throws -> R) async throws -> R {
            let response = try await resource._list(date: date, filter: filter, groupBy: groupBy, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
}
