// Transformed from `anthropic.types.beta.organization.analytics.cost_list_params` (cost_list_params.py).

import Foundation

public struct CostListParams: Codable, Hashable, Sendable {
    /// Start of range, inclusive.
    ///
    /// RFC 3339 tz-aware. Must be within the last 365 days and no earlier than
    /// 2026-01-01T00:00:00Z.
    public var startingAt: StartingAt
    /// Filter to usage attributed to specific identities, by tagged ID: a `user_...`,
    /// `svac_...` (service account), or `apikey_...` ID. An `apikey_` entry matches
    /// only usage attributed to the key itself, not usage on that key attributed to a
    /// user or service account (use `api_key_ids[]` for every request a key
    /// authenticated). Federated identities have no tagged ID; select them with
    /// `actor_types[]`. Use `group_by[]=actor` to break out per-identity values.
    public var actorIDs: [String]??
    /// Filter to usage attributed to specific kinds of identity.
    ///
    /// Use `group_by[]=actor_type` to break out per-kind values.
    public var actorTypes: [BetaAnalyticsActorType]??
    /// Filter to usage incurred by sessions of specific Claude Managed Agents agents.
    ///
    /// Use `group_by[]=agent_id` to break out per-agent values. Claude Developer
    /// Platform organizations only.
    public var agentIDs: [String]??
    /// Filter to usage authenticated by specific API keys, by tagged API key ID
    /// (`apikey_...`), whichever identity the usage is attributed to. Include an empty
    /// entry (`api_key_ids[]=`) to also match usage that no API key authenticated. Use
    /// `group_by[]=api_key_id` to break out per-key values; usage without a key has a
    /// null `api_key_id`. Claude Developer Platform organizations only.
    public var apiKeyIDs: [String]??
    /// Filter to Claude Tag (Claude in Slack) usage in specific spend categories.
    ///
    /// Usage with no category never matches. `dm` usage is reported under the user's
    /// product rather than `claude_tag`, so combining this filter with
    /// `products[]=claude_tag` excludes it. Use `group_by[]=claude_tag_category` to
    /// break out per-category values.
    public var claudeTagCategories: [BetaAnalyticsClaudeTagCategory]??
    /// Filter to Claude Tag (Claude in Slack) usage attributed to specific Slack users,
    /// by Slack user ID (for example `U0123ABCDEF`), not claude.ai user ID. Usage that
    /// is not Claude Tag, and Claude Tag usage not attributed to a single user, never
    /// matches. Use `group_by[]=claude_tag_user_id` to break out per-user values.
    public var claudeTagUserIDs: [String]??
    /// Filter to specific context-window pricing tiers.
    ///
    /// Use `group_by[]=context_window` to break out per-tier values.
    public var contextWindows: [BetaAnalyticsContextWindow]??
    /// Filter to usage incurred by Claude Managed Agents sessions that specific
    /// deployments started. Use `group_by[]=deployment_id` to break out per-deployment
    /// values. Claude Developer Platform organizations only.
    public var deploymentIDs: [String]??
    /// End of range, exclusive.
    ///
    /// Required when `time_bucket_width` is set. Without `time_bucket_width`, defaults
    /// to the earlier of now and `starting_at` + 31 days. The range may span at most 31
    /// days.
    public var endingAt: EndingAt??
    /// Filter to usage incurred by Claude Managed Agents sessions that ran in specific
    /// environments. Use `group_by[]=environment_id` to break out per-environment
    /// values. Claude Developer Platform organizations only.
    public var environmentIDs: [String]??
    /// If true, omit rows whose `actor` is a `user_actor` with `deleted: true`.
    ///
    /// Requires `group_by[]=actor`. Rows for other actor types, and rows whose `actor`
    /// is null, are always kept. A page may contain fewer than `limit` rows; use
    /// `has_more` and `next_page` to paginate as usual.
    public var excludeDeletedUsers: Bool?
    /// Dimensions to break cost out by (at most 5, not counting `cost_type` and
    /// `token_type`): one row per combination of their values with cost in the range
    /// (and per time bucket, when `time_bucket_width` is set), every combination
    /// returned across pages rather than a capped top set. `cost_type` and `token_type`
    /// do not count toward `limit`: `cost_type` returns one row per cost component
    /// (tokens, web search, code execution, and `session_usage`, Claude Managed Agents
    /// session time); `token_type` returns one row per token type, each with
    /// `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    /// web-search, code-execution and session-usage rows. When omitted, a single row
    /// aggregates the whole range.
    public var groupBy: [BetaAnalyticsCostGroupBy]??
    /// Filter to specific inference regions.
    ///
    /// `not_available` matches rows where the region is unset. Use
    /// `group_by[]=inference_geo` to break out per-region values.
    public var inferenceGeos: [BetaAnalyticsInferenceGeoFilter]??
    /// Number of rows per page (1-1000, default 20).
    ///
    /// `cost_type`/`token_type` fan-out rows (cost endpoint only) do not count toward
    /// this limit, so `data` can exceed it.
    public var limit: Int?
    /// Models to include.
    ///
    /// Defaults to all models. Use `group_by[]=model` to break out per-model values.
    public var models: [String]??
    /// Sort direction of the `order_by` metric, or of the time buckets when `order_by`
    /// is `time` and `time_bucket_width` is set. Defaults to `desc`.
    public var order: BetaAnalyticsUsageCostSortOrder?
    /// Row order.
    ///
    /// A metric ranks rows by that metric in the `order` direction. `time` orders rows
    /// by time bucket in the `order` direction (newest first by default) and, within a
    /// bucket, by `amount`, highest first. `time` takes effect only with
    /// `time_bucket_width`; without it, `time` is the same as `amount`. Defaults to
    /// `amount`.
    public var orderBy: BetaAnalyticsCostOrderBy?
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// Product surfaces to include. Defaults to all products.
    public var products: [BetaAnalyticsUsageCostProductFilter]??
    /// Filter to usage attributed to specific RBAC groups.
    ///
    /// Accepts tagged RBAC group IDs (`rbac_group_...`) or bare group UUIDs. A row
    /// matches when the user belonged to any of the listed groups on the (UTC) day the
    /// usage occurred; usage with no group attribution never matches.
    public var rbacGroupIDs: [String]??
    /// Filter to specific service tiers.
    ///
    /// Use `group_by[]=service_tier` to break out per-tier values. Claude Developer
    /// Platform organizations only; matches nothing for a Claude Enterprise
    /// organization.
    public var serviceTiers: [BetaAnalyticsServiceTier]??
    /// Filter to usage incurred by specific Claude Managed Agents sessions, by tagged
    /// session ID (`sesn_...`). Use `group_by[]=session_id` to break out per-session
    /// values. Claude Developer Platform organizations only.
    public var sessionIDs: [String]??
    /// Filter to usage originating from specific Slack channels.
    ///
    /// Use `group_by[]=slack_channel_id` to break out per-channel values.
    public var slackChannelIDs: [String]??
    /// Filter to fast or standard inference mode.
    ///
    /// Use `group_by[]=speed` to break out per-mode values.
    public var speeds: [BetaAnalyticsSpeed]??
    /// Time-bucket granularity.
    ///
    /// When set, rows are returned per time bucket (one per bucket and dimension
    /// combination with usage) and each row's `starting_at` and `ending_at` are that
    /// bucket's bounds; the time bucket counts toward `limit`. `ending_at` is required
    /// when `time_bucket_width` is set, and with `time_bucket_width="1m"` the range may
    /// span at most 24 hours. When omitted, each row aggregates the requested range
    /// with `starting_at` and `ending_at` each rounded down to the hour.
    public var timeBucketWidth: BetaAnalyticsTimeBucketWidth??
    /// Filter to usage attributed to specific user profiles, by tagged user profile ID
    /// (`uprof_...`). Use `group_by[]=user_profile_id` to break out per-profile values.
    /// Claude Developer Platform organizations only.
    public var userProfileIDs: [String]??
    /// Filter to usage in specific workspaces, by tagged workspace ID (`wrkspc_...`).
    ///
    /// Use `group_by[]=workspace_id` to break out per-workspace values. Claude
    /// Developer Platform organizations only; matches nothing for a Claude Enterprise
    /// organization.
    public var workspaceIDs: [String]??
    /// This endpoint is in beta: requests must send `analytics-usage-cost-2026-08-24`
    /// in this header.
    public var betas: [AnthropicBetaParam]?

    public init(startingAt: StartingAt, actorIDs: [String]?? = nil, actorTypes: [BetaAnalyticsActorType]?? = nil, agentIDs: [String]?? = nil, apiKeyIDs: [String]?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, deploymentIDs: [String]?? = nil, endingAt: EndingAt?? = nil, environmentIDs: [String]?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [BetaAnalyticsCostGroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: BetaAnalyticsUsageCostSortOrder? = nil, orderBy: BetaAnalyticsCostOrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsUsageCostProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, serviceTiers: [BetaAnalyticsServiceTier]?? = nil, sessionIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [BetaAnalyticsSpeed]?? = nil, timeBucketWidth: BetaAnalyticsTimeBucketWidth?? = nil, userProfileIDs: [String]?? = nil, workspaceIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.startingAt = startingAt
        self.actorIDs = actorIDs
        self.actorTypes = actorTypes
        self.agentIDs = agentIDs
        self.apiKeyIDs = apiKeyIDs
        self.claudeTagCategories = claudeTagCategories
        self.claudeTagUserIDs = claudeTagUserIDs
        self.contextWindows = contextWindows
        self.deploymentIDs = deploymentIDs
        self.endingAt = endingAt
        self.environmentIDs = environmentIDs
        self.excludeDeletedUsers = excludeDeletedUsers
        self.groupBy = groupBy
        self.inferenceGeos = inferenceGeos
        self.limit = limit
        self.models = models
        self.order = order
        self.orderBy = orderBy
        self.page = page
        self.products = products
        self.rbacGroupIDs = rbacGroupIDs
        self.serviceTiers = serviceTiers
        self.sessionIDs = sessionIDs
        self.slackChannelIDs = slackChannelIDs
        self.speeds = speeds
        self.timeBucketWidth = timeBucketWidth
        self.userProfileIDs = userProfileIDs
        self.workspaceIDs = workspaceIDs
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case startingAt = "starting_at"
        case actorIDs = "actor_ids"
        case actorTypes = "actor_types"
        case agentIDs = "agent_ids"
        case apiKeyIDs = "api_key_ids"
        case claudeTagCategories = "claude_tag_categories"
        case claudeTagUserIDs = "claude_tag_user_ids"
        case contextWindows = "context_windows"
        case deploymentIDs = "deployment_ids"
        case endingAt = "ending_at"
        case environmentIDs = "environment_ids"
        case excludeDeletedUsers = "exclude_deleted_users"
        case groupBy = "group_by"
        case inferenceGeos = "inference_geos"
        case limit
        case models
        case order
        case orderBy = "order_by"
        case page
        case products
        case rbacGroupIDs = "rbac_group_ids"
        case serviceTiers = "service_tiers"
        case sessionIDs = "session_ids"
        case slackChannelIDs = "slack_channel_ids"
        case speeds
        case timeBucketWidth = "time_bucket_width"
        case userProfileIDs = "user_profile_ids"
        case workspaceIDs = "workspace_ids"
        case betas
    }

    public indirect enum StartingAt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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

    public indirect enum EndingAt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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
