// Transformed from `anthropic.resources.beta.organization.analytics.cost` (cost.py).

import Foundation

public struct BetaOrganizationAnalyticsCostResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get cost in USD across a date range, broken out by dimension.
    ///
    /// Returns one row per combination of the requested `group_by[]` dimensions (and
    /// time bucket, when `time_bucket_width` is set) that has cost in the range, ranked
    /// by spend or ordered by time bucket; every combination is returned across pages.
    /// With no `group_by[]` and no `time_bucket_width`, a single row aggregates the
    /// whole range. Includes all cost, whether or not it is attributable to a seat
    /// user. Requires an API key with the `read:analytics` scope, or an Admin API key.
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   actor_ids: Filter to usage attributed to specific identities, by tagged ID: a `user_...`,
    ///       `svac_...` (service account), or `apikey_...` ID. An `apikey_` entry matches
    ///       only usage attributed to the key itself, not usage on that key attributed to a
    ///       user or service account (use `api_key_ids[]` for every request a key
    ///       authenticated). Federated identities have no tagged ID; select them with
    ///       `actor_types[]`. Use `group_by[]=actor` to break out per-identity values.
    ///
    ///   actor_types: Filter to usage attributed to specific kinds of identity. Use
    ///       `group_by[]=actor_type` to break out per-kind values.
    ///
    ///   agent_ids: Filter to usage incurred by sessions of specific Claude Managed Agents agents.
    ///       Use `group_by[]=agent_id` to break out per-agent values. Claude Developer
    ///       Platform organizations only.
    ///
    ///   api_key_ids: Filter to usage authenticated by specific API keys, by tagged API key ID
    ///       (`apikey_...`), whichever identity the usage is attributed to. Include an empty
    ///       entry (`api_key_ids[]=`) to also match usage that no API key authenticated. Use
    ///       `group_by[]=api_key_id` to break out per-key values; usage without a key has a
    ///       null `api_key_id`. Claude Developer Platform organizations only.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude_tag`, so combining this filter with `products[]=claude_tag`
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
    ///   deployment_ids: Filter to usage incurred by Claude Managed Agents sessions that specific
    ///       deployments started. Use `group_by[]=deployment_id` to break out per-deployment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   ending_at: End of range, exclusive. Required when `time_bucket_width` is set. Without
    ///       `time_bucket_width`, defaults to the earlier of now and `starting_at` + 31 days.
    ///       The range may span at most 31 days.
    ///
    ///   environment_ids: Filter to usage incurred by Claude Managed Agents sessions that ran in specific
    ///       environments. Use `group_by[]=environment_id` to break out per-environment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   exclude_deleted_users: If true, omit rows whose `actor` is a `user_actor` with `deleted: true`.
    ///       Requires `group_by[]=actor`. Rows for other actor types, and rows whose `actor`
    ///       is null, are always kept. A page may contain fewer than `limit` rows; use
    ///       `has_more` and `next_page` to paginate as usual.
    ///
    ///   group_by: Dimensions to break cost out by (at most 5, not counting `cost_type` and
    ///       `token_type`): one row per combination of their values with cost in the range
    ///       (and per time bucket, when `time_bucket_width` is set), every combination
    ///       returned across pages rather than a capped top set. `cost_type` and `token_type`
    ///       do not count toward `limit`: `cost_type` returns one row per cost component
    ///       (tokens, web search, code execution, and `session_usage`, Claude Managed Agents
    ///       session time); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search, code-execution and session-usage rows. When omitted, a single row
    ///       aggregates the whole range.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). `cost_type`/`token_type` fan-out
    ///       rows (cost endpoint only) do not count toward this limit, so `data` can exceed
    ///       it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction of the `order_by` metric, or of the time buckets when `order_by`
    ///       is `time` and `time_bucket_width` is set. Defaults to `desc`.
    ///
    ///   order_by: Row order. A metric ranks rows by that metric in the `order` direction. `time`
    ///       orders rows by time bucket in the `order` direction (newest first by default)
    ///       and, within a bucket, by `amount`, highest first. `time` takes effect only with
    ///       `time_bucket_width`; without it, `time` is the same as `amount`. Defaults to
    ///       `amount`.
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
    ///   service_tiers: Filter to specific service tiers. Use `group_by[]=service_tier` to break out
    ///       per-tier values. Claude Developer Platform organizations only; matches nothing
    ///       for a Claude Enterprise organization.
    ///
    ///   session_ids: Filter to usage incurred by specific Claude Managed Agents sessions, by tagged
    ///       session ID (`sesn_...`). Use `group_by[]=session_id` to break out per-session
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   time_bucket_width: Time-bucket granularity. When set, rows are returned per time bucket (one per
    ///       bucket and dimension combination with usage) and each row's `starting_at` and
    ///       `ending_at` are that bucket's bounds; the time bucket counts toward `limit`.
    ///       `ending_at` is required when `time_bucket_width` is set, and with
    ///       `time_bucket_width="1m"` the range may span at most 24 hours. When omitted, each
    ///       row aggregates the requested range with `starting_at` and `ending_at` each
    ///       rounded down to the hour.
    ///
    ///   user_profile_ids: Filter to usage attributed to specific user profiles, by tagged user profile ID
    ///       (`uprof_...`). Use `group_by[]=user_profile_id` to break out per-profile values.
    ///       Claude Developer Platform organizations only.
    ///
    ///   workspace_ids: Filter to usage in specific workspaces, by tagged workspace ID (`wrkspc_...`).
    ///       Use `group_by[]=workspace_id` to break out per-workspace values. Claude
    ///       Developer Platform organizations only; matches nothing for a Claude Enterprise
    ///       organization.
    ///
    ///   betas: This endpoint is in beta: requests must send `analytics-usage-cost-2026-08-24`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(startingAt: CostListParams.StartingAt, actorIDs: [String]?? = nil, actorTypes: [BetaAnalyticsActorType]?? = nil, agentIDs: [String]?? = nil, apiKeyIDs: [String]?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, deploymentIDs: [String]?? = nil, endingAt: CostListParams.EndingAt?? = nil, environmentIDs: [String]?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [BetaAnalyticsCostGroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: BetaAnalyticsUsageCostSortOrder? = nil, orderBy: BetaAnalyticsCostOrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsUsageCostProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, serviceTiers: [BetaAnalyticsServiceTier]?? = nil, sessionIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [BetaAnalyticsSpeed]?? = nil, timeBucketWidth: BetaAnalyticsTimeBucketWidth?? = nil, userProfileIDs: [String]?? = nil, workspaceIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> ReportPageCursor<BetaAnalyticsCostItem> {
        try await _list(startingAt: startingAt, actorIDs: actorIDs, actorTypes: actorTypes, agentIDs: agentIDs, apiKeyIDs: apiKeyIDs, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, deploymentIDs: deploymentIDs, endingAt: endingAt, environmentIDs: environmentIDs, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, serviceTiers: serviceTiers, sessionIDs: sessionIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, timeBucketWidth: timeBucketWidth, userProfileIDs: userProfileIDs, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(startingAt: CostListParams.StartingAt, actorIDs: [String]?? = nil, actorTypes: [BetaAnalyticsActorType]?? = nil, agentIDs: [String]?? = nil, apiKeyIDs: [String]?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, deploymentIDs: [String]?? = nil, endingAt: CostListParams.EndingAt?? = nil, environmentIDs: [String]?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [BetaAnalyticsCostGroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: BetaAnalyticsUsageCostSortOrder? = nil, orderBy: BetaAnalyticsCostOrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsUsageCostProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, serviceTiers: [BetaAnalyticsServiceTier]?? = nil, sessionIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [BetaAnalyticsSpeed]?? = nil, timeBucketWidth: BetaAnalyticsTimeBucketWidth?? = nil, userProfileIDs: [String]?? = nil, workspaceIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<ReportPageCursor<BetaAnalyticsCostItem>> {
        var query = ParamsBuilder()
        try query.set("starting_at", startingAt)
        try query.set("actor_ids", actorIDs)
        try query.set("actor_types", actorTypes)
        try query.set("agent_ids", agentIDs)
        try query.set("api_key_ids", apiKeyIDs)
        try query.set("claude_tag_categories", claudeTagCategories)
        try query.set("claude_tag_user_ids", claudeTagUserIDs)
        try query.set("context_windows", contextWindows)
        try query.set("deployment_ids", deploymentIDs)
        try query.set("ending_at", endingAt)
        try query.set("environment_ids", environmentIDs)
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
        try query.set("service_tiers", serviceTiers)
        try query.set("session_ids", sessionIDs)
        try query.set("slack_channel_ids", slackChannelIDs)
        try query.set("speeds", speeds)
        try query.set("time_bucket_width", timeBucketWidth)
        try query.set("user_profile_ids", userProfileIDs)
        try query.set("workspace_ids", workspaceIDs)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/analytics/cost", query: query, headers: mergeHeaderLayers(["anthropic-beta": "analytics-usage-cost-2026-08-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["analytics-usage-cost-2026-08-24"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.analytics.cost.list")
        return try await client.requestPageResponse(ReportPageCursor<BetaAnalyticsCostItem>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsCostResource

    /// Get cost in USD across a date range, broken out by dimension.
    ///
    /// Returns one row per combination of the requested `group_by[]` dimensions (and
    /// time bucket, when `time_bucket_width` is set) that has cost in the range, ranked
    /// by spend or ordered by time bucket; every combination is returned across pages.
    /// With no `group_by[]` and no `time_bucket_width`, a single row aggregates the
    /// whole range. Includes all cost, whether or not it is attributable to a seat
    /// user. Requires an API key with the `read:analytics` scope, or an Admin API key.
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   actor_ids: Filter to usage attributed to specific identities, by tagged ID: a `user_...`,
    ///       `svac_...` (service account), or `apikey_...` ID. An `apikey_` entry matches
    ///       only usage attributed to the key itself, not usage on that key attributed to a
    ///       user or service account (use `api_key_ids[]` for every request a key
    ///       authenticated). Federated identities have no tagged ID; select them with
    ///       `actor_types[]`. Use `group_by[]=actor` to break out per-identity values.
    ///
    ///   actor_types: Filter to usage attributed to specific kinds of identity. Use
    ///       `group_by[]=actor_type` to break out per-kind values.
    ///
    ///   agent_ids: Filter to usage incurred by sessions of specific Claude Managed Agents agents.
    ///       Use `group_by[]=agent_id` to break out per-agent values. Claude Developer
    ///       Platform organizations only.
    ///
    ///   api_key_ids: Filter to usage authenticated by specific API keys, by tagged API key ID
    ///       (`apikey_...`), whichever identity the usage is attributed to. Include an empty
    ///       entry (`api_key_ids[]=`) to also match usage that no API key authenticated. Use
    ///       `group_by[]=api_key_id` to break out per-key values; usage without a key has a
    ///       null `api_key_id`. Claude Developer Platform organizations only.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude_tag`, so combining this filter with `products[]=claude_tag`
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
    ///   deployment_ids: Filter to usage incurred by Claude Managed Agents sessions that specific
    ///       deployments started. Use `group_by[]=deployment_id` to break out per-deployment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   ending_at: End of range, exclusive. Required when `time_bucket_width` is set. Without
    ///       `time_bucket_width`, defaults to the earlier of now and `starting_at` + 31 days.
    ///       The range may span at most 31 days.
    ///
    ///   environment_ids: Filter to usage incurred by Claude Managed Agents sessions that ran in specific
    ///       environments. Use `group_by[]=environment_id` to break out per-environment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   exclude_deleted_users: If true, omit rows whose `actor` is a `user_actor` with `deleted: true`.
    ///       Requires `group_by[]=actor`. Rows for other actor types, and rows whose `actor`
    ///       is null, are always kept. A page may contain fewer than `limit` rows; use
    ///       `has_more` and `next_page` to paginate as usual.
    ///
    ///   group_by: Dimensions to break cost out by (at most 5, not counting `cost_type` and
    ///       `token_type`): one row per combination of their values with cost in the range
    ///       (and per time bucket, when `time_bucket_width` is set), every combination
    ///       returned across pages rather than a capped top set. `cost_type` and `token_type`
    ///       do not count toward `limit`: `cost_type` returns one row per cost component
    ///       (tokens, web search, code execution, and `session_usage`, Claude Managed Agents
    ///       session time); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search, code-execution and session-usage rows. When omitted, a single row
    ///       aggregates the whole range.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). `cost_type`/`token_type` fan-out
    ///       rows (cost endpoint only) do not count toward this limit, so `data` can exceed
    ///       it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction of the `order_by` metric, or of the time buckets when `order_by`
    ///       is `time` and `time_bucket_width` is set. Defaults to `desc`.
    ///
    ///   order_by: Row order. A metric ranks rows by that metric in the `order` direction. `time`
    ///       orders rows by time bucket in the `order` direction (newest first by default)
    ///       and, within a bucket, by `amount`, highest first. `time` takes effect only with
    ///       `time_bucket_width`; without it, `time` is the same as `amount`. Defaults to
    ///       `amount`.
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
    ///   service_tiers: Filter to specific service tiers. Use `group_by[]=service_tier` to break out
    ///       per-tier values. Claude Developer Platform organizations only; matches nothing
    ///       for a Claude Enterprise organization.
    ///
    ///   session_ids: Filter to usage incurred by specific Claude Managed Agents sessions, by tagged
    ///       session ID (`sesn_...`). Use `group_by[]=session_id` to break out per-session
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   time_bucket_width: Time-bucket granularity. When set, rows are returned per time bucket (one per
    ///       bucket and dimension combination with usage) and each row's `starting_at` and
    ///       `ending_at` are that bucket's bounds; the time bucket counts toward `limit`.
    ///       `ending_at` is required when `time_bucket_width` is set, and with
    ///       `time_bucket_width="1m"` the range may span at most 24 hours. When omitted, each
    ///       row aggregates the requested range with `starting_at` and `ending_at` each
    ///       rounded down to the hour.
    ///
    ///   user_profile_ids: Filter to usage attributed to specific user profiles, by tagged user profile ID
    ///       (`uprof_...`). Use `group_by[]=user_profile_id` to break out per-profile values.
    ///       Claude Developer Platform organizations only.
    ///
    ///   workspace_ids: Filter to usage in specific workspaces, by tagged workspace ID (`wrkspc_...`).
    ///       Use `group_by[]=workspace_id` to break out per-workspace values. Claude
    ///       Developer Platform organizations only; matches nothing for a Claude Enterprise
    ///       organization.
    ///
    ///   betas: This endpoint is in beta: requests must send `analytics-usage-cost-2026-08-24`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(startingAt: CostListParams.StartingAt, actorIDs: [String]?? = nil, actorTypes: [BetaAnalyticsActorType]?? = nil, agentIDs: [String]?? = nil, apiKeyIDs: [String]?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, deploymentIDs: [String]?? = nil, endingAt: CostListParams.EndingAt?? = nil, environmentIDs: [String]?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [BetaAnalyticsCostGroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: BetaAnalyticsUsageCostSortOrder? = nil, orderBy: BetaAnalyticsCostOrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsUsageCostProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, serviceTiers: [BetaAnalyticsServiceTier]?? = nil, sessionIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [BetaAnalyticsSpeed]?? = nil, timeBucketWidth: BetaAnalyticsTimeBucketWidth?? = nil, userProfileIDs: [String]?? = nil, workspaceIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<ReportPageCursor<BetaAnalyticsCostItem>> {
            try await resource._list(startingAt: startingAt, actorIDs: actorIDs, actorTypes: actorTypes, agentIDs: agentIDs, apiKeyIDs: apiKeyIDs, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, deploymentIDs: deploymentIDs, endingAt: endingAt, environmentIDs: environmentIDs, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, serviceTiers: serviceTiers, sessionIDs: sessionIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, timeBucketWidth: timeBucketWidth, userProfileIDs: userProfileIDs, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsCostResource

    /// Get cost in USD across a date range, broken out by dimension.
    ///
    /// Returns one row per combination of the requested `group_by[]` dimensions (and
    /// time bucket, when `time_bucket_width` is set) that has cost in the range, ranked
    /// by spend or ordered by time bucket; every combination is returned across pages.
    /// With no `group_by[]` and no `time_bucket_width`, a single row aggregates the
    /// whole range. Includes all cost, whether or not it is attributable to a seat
    /// user. Requires an API key with the `read:analytics` scope, or an Admin API key.
    ///
    /// Args:
    ///   starting_at: Start of range, inclusive. RFC 3339 tz-aware. Must be within the last 365 days
    ///       and no earlier than 2026-01-01T00:00:00Z.
    ///
    ///   actor_ids: Filter to usage attributed to specific identities, by tagged ID: a `user_...`,
    ///       `svac_...` (service account), or `apikey_...` ID. An `apikey_` entry matches
    ///       only usage attributed to the key itself, not usage on that key attributed to a
    ///       user or service account (use `api_key_ids[]` for every request a key
    ///       authenticated). Federated identities have no tagged ID; select them with
    ///       `actor_types[]`. Use `group_by[]=actor` to break out per-identity values.
    ///
    ///   actor_types: Filter to usage attributed to specific kinds of identity. Use
    ///       `group_by[]=actor_type` to break out per-kind values.
    ///
    ///   agent_ids: Filter to usage incurred by sessions of specific Claude Managed Agents agents.
    ///       Use `group_by[]=agent_id` to break out per-agent values. Claude Developer
    ///       Platform organizations only.
    ///
    ///   api_key_ids: Filter to usage authenticated by specific API keys, by tagged API key ID
    ///       (`apikey_...`), whichever identity the usage is attributed to. Include an empty
    ///       entry (`api_key_ids[]=`) to also match usage that no API key authenticated. Use
    ///       `group_by[]=api_key_id` to break out per-key values; usage without a key has a
    ///       null `api_key_id`. Claude Developer Platform organizations only.
    ///
    ///   claude_tag_categories: Filter to Claude Tag (Claude in Slack) usage in specific spend categories. Usage
    ///       with no category never matches. `dm` usage is reported under the user's product
    ///       rather than `claude_tag`, so combining this filter with `products[]=claude_tag`
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
    ///   deployment_ids: Filter to usage incurred by Claude Managed Agents sessions that specific
    ///       deployments started. Use `group_by[]=deployment_id` to break out per-deployment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   ending_at: End of range, exclusive. Required when `time_bucket_width` is set. Without
    ///       `time_bucket_width`, defaults to the earlier of now and `starting_at` + 31 days.
    ///       The range may span at most 31 days.
    ///
    ///   environment_ids: Filter to usage incurred by Claude Managed Agents sessions that ran in specific
    ///       environments. Use `group_by[]=environment_id` to break out per-environment
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   exclude_deleted_users: If true, omit rows whose `actor` is a `user_actor` with `deleted: true`.
    ///       Requires `group_by[]=actor`. Rows for other actor types, and rows whose `actor`
    ///       is null, are always kept. A page may contain fewer than `limit` rows; use
    ///       `has_more` and `next_page` to paginate as usual.
    ///
    ///   group_by: Dimensions to break cost out by (at most 5, not counting `cost_type` and
    ///       `token_type`): one row per combination of their values with cost in the range
    ///       (and per time bucket, when `time_bucket_width` is set), every combination
    ///       returned across pages rather than a capped top set. `cost_type` and `token_type`
    ///       do not count toward `limit`: `cost_type` returns one row per cost component
    ///       (tokens, web search, code execution, and `session_usage`, Claude Managed Agents
    ///       session time); `token_type` returns one row per token type, each with
    ///       `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    ///       web-search, code-execution and session-usage rows. When omitted, a single row
    ///       aggregates the whole range.
    ///
    ///   inference_geos: Filter to specific inference regions. `not_available` matches rows where the
    ///       region is unset. Use `group_by[]=inference_geo` to break out per-region values.
    ///
    ///   limit: Number of rows per page (1-1000, default 20). `cost_type`/`token_type` fan-out
    ///       rows (cost endpoint only) do not count toward this limit, so `data` can exceed
    ///       it.
    ///
    ///   models: Models to include. Defaults to all models. Use `group_by[]=model` to break out
    ///       per-model values.
    ///
    ///   order: Sort direction of the `order_by` metric, or of the time buckets when `order_by`
    ///       is `time` and `time_bucket_width` is set. Defaults to `desc`.
    ///
    ///   order_by: Row order. A metric ranks rows by that metric in the `order` direction. `time`
    ///       orders rows by time bucket in the `order` direction (newest first by default)
    ///       and, within a bucket, by `amount`, highest first. `time` takes effect only with
    ///       `time_bucket_width`; without it, `time` is the same as `amount`. Defaults to
    ///       `amount`.
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
    ///   service_tiers: Filter to specific service tiers. Use `group_by[]=service_tier` to break out
    ///       per-tier values. Claude Developer Platform organizations only; matches nothing
    ///       for a Claude Enterprise organization.
    ///
    ///   session_ids: Filter to usage incurred by specific Claude Managed Agents sessions, by tagged
    ///       session ID (`sesn_...`). Use `group_by[]=session_id` to break out per-session
    ///       values. Claude Developer Platform organizations only.
    ///
    ///   slack_channel_ids: Filter to usage originating from specific Slack channels. Use
    ///       `group_by[]=slack_channel_id` to break out per-channel values.
    ///
    ///   speeds: Filter to fast or standard inference mode. Use `group_by[]=speed` to break out
    ///       per-mode values.
    ///
    ///   time_bucket_width: Time-bucket granularity. When set, rows are returned per time bucket (one per
    ///       bucket and dimension combination with usage) and each row's `starting_at` and
    ///       `ending_at` are that bucket's bounds; the time bucket counts toward `limit`.
    ///       `ending_at` is required when `time_bucket_width` is set, and with
    ///       `time_bucket_width="1m"` the range may span at most 24 hours. When omitted, each
    ///       row aggregates the requested range with `starting_at` and `ending_at` each
    ///       rounded down to the hour.
    ///
    ///   user_profile_ids: Filter to usage attributed to specific user profiles, by tagged user profile ID
    ///       (`uprof_...`). Use `group_by[]=user_profile_id` to break out per-profile values.
    ///       Claude Developer Platform organizations only.
    ///
    ///   workspace_ids: Filter to usage in specific workspaces, by tagged workspace ID (`wrkspc_...`).
    ///       Use `group_by[]=workspace_id` to break out per-workspace values. Claude
    ///       Developer Platform organizations only; matches nothing for a Claude Enterprise
    ///       organization.
    ///
    ///   betas: This endpoint is in beta: requests must send `analytics-usage-cost-2026-08-24`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(startingAt: CostListParams.StartingAt, actorIDs: [String]?? = nil, actorTypes: [BetaAnalyticsActorType]?? = nil, agentIDs: [String]?? = nil, apiKeyIDs: [String]?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, deploymentIDs: [String]?? = nil, endingAt: CostListParams.EndingAt?? = nil, environmentIDs: [String]?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [BetaAnalyticsCostGroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: BetaAnalyticsUsageCostSortOrder? = nil, orderBy: BetaAnalyticsCostOrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsUsageCostProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, serviceTiers: [BetaAnalyticsServiceTier]?? = nil, sessionIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [BetaAnalyticsSpeed]?? = nil, timeBucketWidth: BetaAnalyticsTimeBucketWidth?? = nil, userProfileIDs: [String]?? = nil, workspaceIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<ReportPageCursor<BetaAnalyticsCostItem>>) async throws -> R) async throws -> R {
            let response = try await resource._list(startingAt: startingAt, actorIDs: actorIDs, actorTypes: actorTypes, agentIDs: agentIDs, apiKeyIDs: apiKeyIDs, claudeTagCategories: claudeTagCategories, claudeTagUserIDs: claudeTagUserIDs, contextWindows: contextWindows, deploymentIDs: deploymentIDs, endingAt: endingAt, environmentIDs: environmentIDs, excludeDeletedUsers: excludeDeletedUsers, groupBy: groupBy, inferenceGeos: inferenceGeos, limit: limit, models: models, order: order, orderBy: orderBy, page: page, products: products, rbacGroupIDs: rbacGroupIDs, serviceTiers: serviceTiers, sessionIDs: sessionIDs, slackChannelIDs: slackChannelIDs, speeds: speeds, timeBucketWidth: timeBucketWidth, userProfileIDs: userProfileIDs, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
