// Transformed from `anthropic.resources.beta.organization.analytics.user_cost_report` (user_cost_report.py).

import Foundation

public struct BetaOrganizationAnalyticsUserCostReportResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// [Legacy] Get per-user cost in USD across a date range.
    ///
    /// Returns cost per user, ranked by spend; `group_by[]` or `bucket_width` splits a
    /// user across several rows. Use this to see which users account for the most cost.
    /// Only cost attributed to a user account is included; cost with no user attributed
    /// to it, such as Code Review usage and Claude Tag usage in Slack channels, is left
    /// out. Available to organizations on a Claude Enterprise plan. Requires an API key
    /// with the `read:analytics` scope.
    ///
    /// This endpoint is one of the legacy Claude Enterprise usage and cost reports. For
    /// new integrations, use
    /// [`GET /v1/organizations/analytics/cost`](/docs/en/api/beta/organization/analytics/cost/list)
    /// in the Usage and Cost Analytics API instead. To move an existing integration,
    /// see
    /// [Migrate from the Claude Enterprise usage and cost reports](/docs/en/manage-claude/usage-cost-analytics-api#migrate-from-enterprise-analytics-reports).
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   bucket_width: Time-bucket granularity. When set, each row's `starting_at` and `ending_at` are
    ///       populated and one actor may span several rows (one per time bucket with usage).
    ///       The time bucket counts toward `limit`, so one page can return multiple rows for
    ///       the same actor. `ending_at` is required when `bucket_width` is set, and with
    ///       `bucket_width="1m"` the range may span at most 24 hours. When omitted, each row
    ///       aggregates the full `[starting_at, ending_at)` range.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude-tag`, so combining this filter with `products[]=claude-tag`
    ///       excludes it. Use `group_by[]=claude_tag_category` to break out per-category
    ///       values.
    ///
    ///   claude_tag_user_ids: Filter to Claude Tag (Claude in Slack) usage attributed to specific Slack users,
    ///       by Slack user ID (for example `U0123ABCDEF`), not claude.ai user ID. Usage that
    ///       is not Claude Tag, and Claude Tag usage not attributed to a single user, never
    ///       matches. Use `group_by[]=claude_tag_user_id` to break out per-user values.
    ///
    ///   context_windows: Filter to specific context-window pricing tiers. Use `group_by[]=context_window`
    ///       to break out per-tier values.
    ///
    ///   ending_at: End of range, exclusive. When omitted, defaults to the earlier of now and
    ///       `starting_at` + 31 days. The range may span at most 31 days.
    ///
    ///   exclude_deleted_users: If true, omit rows for users who are deleted (`deleted: true`). A page may
    ///       contain fewer than `limit` rows; use `has_more` and `next_page` to paginate as
    ///       usual.
    ///
    ///   group_by: Break each actor's row out by the given dimensions. Accepts the same values as
    ///       the bucketed `/cost_report` endpoint. The `product`, `model`, `context_window`,
    ///       `inference_geo`, and `speed` dimensions — and the time bucket, when
    ///       `bucket_width` is set — count toward `limit`. `cost_type` and `token_type` do
    ///       not: `cost_type` returns one row per cost component (tokens, web search, code
    ///       execution); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search and code-execution rows. A page can therefore contain more rows than
    ///       `limit` when `cost_type` or `token_type` is requested.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). One row per actor unless
    ///       `group_by[]` or `bucket_width` splits an actor across rows;
    ///       `cost_type`/`token_type` fan-out rows (cost endpoint only) are the exception —
    ///       they do not count toward this limit, so `data` can exceed it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction. Defaults to `desc`.
    ///
    ///   order_by: Metric to rank actors by. Defaults to `amount`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   products: Product surfaces to include. Defaults to all products.
    ///
    ///   rbac_group_ids: Filter to usage attributed to specific RBAC groups. Accepts tagged RBAC group
    ///       IDs (`rbac_group_...`) or bare group UUIDs. A row matches when the user belonged
    ///       to any of the listed groups on the (UTC) day the usage occurred; usage with no
    ///       group attribution never matches.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   user_ids: Filter to specific users by tagged user ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(startingAt: UserCostReportListParams.StartingAt, bucketWidth: UserCostReportListParams.BucketWidth?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: UserCostReportListParams.EndingAt?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [UserCostReportListParams.GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: UserCostReportListParams.Order? = nil, orderBy: UserCostReportListParams.OrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [UserCostReportListParams.Speeds]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ReportPageCursor<BetaAnalyticsCostUsersItem> {
        try await _list(startingAt: startingAt, bucketWidth: bucketWidth, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, endingAt: endingAt, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(startingAt: UserCostReportListParams.StartingAt, bucketWidth: UserCostReportListParams.BucketWidth?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: UserCostReportListParams.EndingAt?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [UserCostReportListParams.GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: UserCostReportListParams.Order? = nil, orderBy: UserCostReportListParams.OrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [UserCostReportListParams.Speeds]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ReportPageCursor<BetaAnalyticsCostUsersItem>> {
        var query = ParamsBuilder()
        try query.set("starting_at", startingAt)
        try query.set("bucket_width", bucketWidth)
        try query.set("claude_tag_categories", claudeTagCategories)
        try query.set("claude_tag_user_ids", claudeTagUserIDs)
        try query.set("context_windows", contextWindows)
        try query.set("ending_at", endingAt)
        try query.set("exclude_deleted_users", excludeDeletedUsers)
        try query.set("group_by", groupBy)
        try query.set("inference_geos", inferenceGeos)
        try query.set("limit", limit)
        try query.set("models", models)
        try query.set("order", order)
        try query.set("order_by", orderBy)
        try query.set("page", page)
        try query.set("products", products)
        try query.set("rbac_group_ids", rbacGroupIDs)
        try query.set("slack_channel_ids", slackChannelIDs)
        try query.set("speeds", speeds)
        try query.set("user_ids", userIDs)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/analytics/user_cost_report", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.analytics.user_cost_report.list", spanRoute: "/v1/organizations/analytics/user_cost_report", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(ReportPageCursor<BetaAnalyticsCostUsersItem>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsUserCostReportResource

    /// [Legacy] Get per-user cost in USD across a date range.
    ///
    /// Returns cost per user, ranked by spend; `group_by[]` or `bucket_width` splits a
    /// user across several rows. Use this to see which users account for the most cost.
    /// Only cost attributed to a user account is included; cost with no user attributed
    /// to it, such as Code Review usage and Claude Tag usage in Slack channels, is left
    /// out. Available to organizations on a Claude Enterprise plan. Requires an API key
    /// with the `read:analytics` scope.
    ///
    /// This endpoint is one of the legacy Claude Enterprise usage and cost reports. For
    /// new integrations, use
    /// [`GET /v1/organizations/analytics/cost`](/docs/en/api/beta/organization/analytics/cost/list)
    /// in the Usage and Cost Analytics API instead. To move an existing integration,
    /// see
    /// [Migrate from the Claude Enterprise usage and cost reports](/docs/en/manage-claude/usage-cost-analytics-api#migrate-from-enterprise-analytics-reports).
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   bucket_width: Time-bucket granularity. When set, each row's `starting_at` and `ending_at` are
    ///       populated and one actor may span several rows (one per time bucket with usage).
    ///       The time bucket counts toward `limit`, so one page can return multiple rows for
    ///       the same actor. `ending_at` is required when `bucket_width` is set, and with
    ///       `bucket_width="1m"` the range may span at most 24 hours. When omitted, each row
    ///       aggregates the full `[starting_at, ending_at)` range.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude-tag`, so combining this filter with `products[]=claude-tag`
    ///       excludes it. Use `group_by[]=claude_tag_category` to break out per-category
    ///       values.
    ///
    ///   claude_tag_user_ids: Filter to Claude Tag (Claude in Slack) usage attributed to specific Slack users,
    ///       by Slack user ID (for example `U0123ABCDEF`), not claude.ai user ID. Usage that
    ///       is not Claude Tag, and Claude Tag usage not attributed to a single user, never
    ///       matches. Use `group_by[]=claude_tag_user_id` to break out per-user values.
    ///
    ///   context_windows: Filter to specific context-window pricing tiers. Use `group_by[]=context_window`
    ///       to break out per-tier values.
    ///
    ///   ending_at: End of range, exclusive. When omitted, defaults to the earlier of now and
    ///       `starting_at` + 31 days. The range may span at most 31 days.
    ///
    ///   exclude_deleted_users: If true, omit rows for users who are deleted (`deleted: true`). A page may
    ///       contain fewer than `limit` rows; use `has_more` and `next_page` to paginate as
    ///       usual.
    ///
    ///   group_by: Break each actor's row out by the given dimensions. Accepts the same values as
    ///       the bucketed `/cost_report` endpoint. The `product`, `model`, `context_window`,
    ///       `inference_geo`, and `speed` dimensions — and the time bucket, when
    ///       `bucket_width` is set — count toward `limit`. `cost_type` and `token_type` do
    ///       not: `cost_type` returns one row per cost component (tokens, web search, code
    ///       execution); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search and code-execution rows. A page can therefore contain more rows than
    ///       `limit` when `cost_type` or `token_type` is requested.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). One row per actor unless
    ///       `group_by[]` or `bucket_width` splits an actor across rows;
    ///       `cost_type`/`token_type` fan-out rows (cost endpoint only) are the exception —
    ///       they do not count toward this limit, so `data` can exceed it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction. Defaults to `desc`.
    ///
    ///   order_by: Metric to rank actors by. Defaults to `amount`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   products: Product surfaces to include. Defaults to all products.
    ///
    ///   rbac_group_ids: Filter to usage attributed to specific RBAC groups. Accepts tagged RBAC group
    ///       IDs (`rbac_group_...`) or bare group UUIDs. A row matches when the user belonged
    ///       to any of the listed groups on the (UTC) day the usage occurred; usage with no
    ///       group attribution never matches.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   user_ids: Filter to specific users by tagged user ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(startingAt: UserCostReportListParams.StartingAt, bucketWidth: UserCostReportListParams.BucketWidth?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: UserCostReportListParams.EndingAt?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [UserCostReportListParams.GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: UserCostReportListParams.Order? = nil, orderBy: UserCostReportListParams.OrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [UserCostReportListParams.Speeds]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ReportPageCursor<BetaAnalyticsCostUsersItem>> {
            try await resource._list(startingAt: startingAt, bucketWidth: bucketWidth, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, endingAt: endingAt, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsUserCostReportResource

    /// [Legacy] Get per-user cost in USD across a date range.
    ///
    /// Returns cost per user, ranked by spend; `group_by[]` or `bucket_width` splits a
    /// user across several rows. Use this to see which users account for the most cost.
    /// Only cost attributed to a user account is included; cost with no user attributed
    /// to it, such as Code Review usage and Claude Tag usage in Slack channels, is left
    /// out. Available to organizations on a Claude Enterprise plan. Requires an API key
    /// with the `read:analytics` scope.
    ///
    /// This endpoint is one of the legacy Claude Enterprise usage and cost reports. For
    /// new integrations, use
    /// [`GET /v1/organizations/analytics/cost`](/docs/en/api/beta/organization/analytics/cost/list)
    /// in the Usage and Cost Analytics API instead. To move an existing integration,
    /// see
    /// [Migrate from the Claude Enterprise usage and cost reports](/docs/en/manage-claude/usage-cost-analytics-api#migrate-from-enterprise-analytics-reports).
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   bucket_width: Time-bucket granularity. When set, each row's `starting_at` and `ending_at` are
    ///       populated and one actor may span several rows (one per time bucket with usage).
    ///       The time bucket counts toward `limit`, so one page can return multiple rows for
    ///       the same actor. `ending_at` is required when `bucket_width` is set, and with
    ///       `bucket_width="1m"` the range may span at most 24 hours. When omitted, each row
    ///       aggregates the full `[starting_at, ending_at)` range.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude-tag`, so combining this filter with `products[]=claude-tag`
    ///       excludes it. Use `group_by[]=claude_tag_category` to break out per-category
    ///       values.
    ///
    ///   claude_tag_user_ids: Filter to Claude Tag (Claude in Slack) usage attributed to specific Slack users,
    ///       by Slack user ID (for example `U0123ABCDEF`), not claude.ai user ID. Usage that
    ///       is not Claude Tag, and Claude Tag usage not attributed to a single user, never
    ///       matches. Use `group_by[]=claude_tag_user_id` to break out per-user values.
    ///
    ///   context_windows: Filter to specific context-window pricing tiers. Use `group_by[]=context_window`
    ///       to break out per-tier values.
    ///
    ///   ending_at: End of range, exclusive. When omitted, defaults to the earlier of now and
    ///       `starting_at` + 31 days. The range may span at most 31 days.
    ///
    ///   exclude_deleted_users: If true, omit rows for users who are deleted (`deleted: true`). A page may
    ///       contain fewer than `limit` rows; use `has_more` and `next_page` to paginate as
    ///       usual.
    ///
    ///   group_by: Break each actor's row out by the given dimensions. Accepts the same values as
    ///       the bucketed `/cost_report` endpoint. The `product`, `model`, `context_window`,
    ///       `inference_geo`, and `speed` dimensions — and the time bucket, when
    ///       `bucket_width` is set — count toward `limit`. `cost_type` and `token_type` do
    ///       not: `cost_type` returns one row per cost component (tokens, web search, code
    ///       execution); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search and code-execution rows. A page can therefore contain more rows than
    ///       `limit` when `cost_type` or `token_type` is requested.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). One row per actor unless
    ///       `group_by[]` or `bucket_width` splits an actor across rows;
    ///       `cost_type`/`token_type` fan-out rows (cost endpoint only) are the exception —
    ///       they do not count toward this limit, so `data` can exceed it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction. Defaults to `desc`.
    ///
    ///   order_by: Metric to rank actors by. Defaults to `amount`.
    ///
    ///   page: Opaque cursor from a previous response's `next_page` field.
    ///
    ///   products: Product surfaces to include. Defaults to all products.
    ///
    ///   rbac_group_ids: Filter to usage attributed to specific RBAC groups. Accepts tagged RBAC group
    ///       IDs (`rbac_group_...`) or bare group UUIDs. A row matches when the user belonged
    ///       to any of the listed groups on the (UTC) day the usage occurred; usage with no
    ///       group attribution never matches.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   user_ids: Filter to specific users by tagged user ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(startingAt: UserCostReportListParams.StartingAt, bucketWidth: UserCostReportListParams.BucketWidth?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: UserCostReportListParams.EndingAt?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [UserCostReportListParams.GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: UserCostReportListParams.Order? = nil, orderBy: UserCostReportListParams.OrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [UserCostReportListParams.Speeds]?? = nil, userIDs: [String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ReportPageCursor<BetaAnalyticsCostUsersItem>>) async throws -> R) async throws -> R {
            let response = try await resource._list(startingAt: startingAt, bucketWidth: bucketWidth, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, endingAt: endingAt, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, userIDs: userIDs, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
