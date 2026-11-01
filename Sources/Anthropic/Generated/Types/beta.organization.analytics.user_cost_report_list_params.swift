// Transformed from `anthropic.types.beta.organization.analytics.user_cost_report_list_params` (user_cost_report_list_params.py).

import Foundation

public struct UserCostReportListParams: Codable, Hashable, Sendable {
    /// Start of range, inclusive.
    ///
    /// RFC 3339 tz-aware. Must be within the last 365 days and no earlier than
    /// 2026-01-01T00:00:00Z.
    public var startingAt: StartingAt
    /// Time-bucket granularity.
    ///
    /// When set, each row's `starting_at` and `ending_at` are populated and one actor
    /// may span several rows (one per time bucket with usage). The time bucket counts
    /// toward `limit`, so one page can return multiple rows for the same actor.
    /// `ending_at` is required when `bucket_width` is set, and with `bucket_width="1m"`
    /// the range may span at most 24 hours. When omitted, each row aggregates the full
    /// `[starting_at, ending_at)` range.
    public var bucketWidth: BucketWidth??
    /// Filter to Claude Tag (Claude in Slack) usage in specific spend categories.
    ///
    /// Usage with no category never matches. `dm` usage is reported under the user's
    /// product rather than `claude-tag`, so combining this filter with
    /// `products[]=claude-tag` excludes it. Use `group_by[]=claude_tag_category` to
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
    /// End of range, exclusive.
    ///
    /// When omitted, defaults to the earlier of now and `starting_at` + 31 days. The
    /// range may span at most 31 days.
    public var endingAt: EndingAt??
    /// If true, omit rows for users who are deleted (`deleted: true`).
    ///
    /// A page may contain fewer than `limit` rows; use `has_more` and `next_page` to
    /// paginate as usual.
    public var excludeDeletedUsers: Bool?
    /// Break each actor's row out by the given dimensions.
    ///
    /// Accepts the same values as the bucketed `/cost_report` endpoint. The `product`,
    /// `model`, `context_window`, `inference_geo`, and `speed` dimensions — and the
    /// time bucket, when `bucket_width` is set — count toward `limit`. `cost_type` and
    /// `token_type` do not: `cost_type` returns one row per cost component (tokens, web
    /// search, code execution); `token_type` returns one row per token type, each with
    /// `cost_type: "tokens"`; combining both returns the per-token-type rows plus the
    /// web-search and code-execution rows. A page can therefore contain more rows than
    /// `limit` when `cost_type` or `token_type` is requested.
    public var groupBy: [GroupBy]??
    /// Filter to specific inference regions.
    ///
    /// `not_available` matches rows where the region is unset. Use
    /// `group_by[]=inference_geo` to break out per-region values.
    public var inferenceGeos: [BetaAnalyticsInferenceGeoFilter]??
    /// Number of rows per page (1-1000, default 20).
    ///
    /// One row per actor unless `group_by[]` or `bucket_width` splits an actor across
    /// rows; `cost_type`/`token_type` fan-out rows (cost endpoint only) are the
    /// exception — they do not count toward this limit, so `data` can exceed it.
    public var limit: Int?
    /// Models to include.
    ///
    /// Defaults to all models. Use `group_by[]=model` to break out per-model values.
    public var models: [String]??
    /// Sort direction. Defaults to `desc`.
    public var order: Order?
    /// Metric to rank actors by. Defaults to `amount`.
    public var orderBy: OrderBy?
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// Product surfaces to include. Defaults to all products.
    public var products: [BetaAnalyticsProductFilter]??
    /// Filter to usage attributed to specific RBAC groups.
    ///
    /// Accepts tagged RBAC group IDs (`rbac_group_...`) or bare group UUIDs. A row
    /// matches when the user belonged to any of the listed groups on the (UTC) day the
    /// usage occurred; usage with no group attribution never matches.
    public var rbacGroupIDs: [String]??
    /// Filter to usage originating from specific Slack channels.
    ///
    /// Use `group_by[]=slack_channel_id` to break out per-channel values.
    public var slackChannelIDs: [String]??
    /// Filter to fast or standard inference mode.
    ///
    /// Use `group_by[]=speed` to break out per-mode values.
    public var speeds: [Speeds]??
    /// Filter to specific users by tagged user ID.
    public var userIDs: [String]??

    public init(startingAt: StartingAt, bucketWidth: BucketWidth?? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: EndingAt?? = nil, excludeDeletedUsers: Bool? = nil, groupBy: [GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int? = nil, models: [String]?? = nil, order: Order? = nil, orderBy: OrderBy? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [Speeds]?? = nil, userIDs: [String]?? = nil) {
        self.startingAt = startingAt
        self.bucketWidth = bucketWidth
        self.claudeTagCategories = claudeTagCategories
        self.claudeTagUserIDs = claudeTagUserIDs
        self.contextWindows = contextWindows
        self.endingAt = endingAt
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
        self.slackChannelIDs = slackChannelIDs
        self.speeds = speeds
        self.userIDs = userIDs
    }

    enum CodingKeys: String, CodingKey {
        case startingAt = "starting_at"
        case bucketWidth = "bucket_width"
        case claudeTagCategories = "claude_tag_categories"
        case claudeTagUserIDs = "claude_tag_user_ids"
        case contextWindows = "context_windows"
        case endingAt = "ending_at"
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
        case slackChannelIDs = "slack_channel_ids"
        case speeds
        case userIDs = "user_ids"
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

    public enum BucketWidth: OpenEnum, CaseIterable {
        case _1d
        case _1h
        case _1m
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [BucketWidth] = [._1d, ._1h, ._1m]

        public init(rawValue: String) {
            switch rawValue {
            case "1d": self = ._1d
            case "1h": self = ._1h
            case "1m": self = ._1m
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case ._1d: return "1d"
            case ._1h: return "1h"
            case ._1m: return "1m"
            case .unknown(let value): return value
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

    public enum GroupBy: OpenEnum, CaseIterable {
        case claudeTagCategory
        case claudeTagUserId
        case contextWindow
        case costType
        case inferenceGeo
        case model
        case product
        case rbacGroupId
        case slackChannelId
        case speed
        case tokenType
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [GroupBy] = [.claudeTagCategory, .claudeTagUserId, .contextWindow, .costType, .inferenceGeo, .model, .product, .rbacGroupId, .slackChannelId, .speed, .tokenType]

        public init(rawValue: String) {
            switch rawValue {
            case "claude_tag_category": self = .claudeTagCategory
            case "claude_tag_user_id": self = .claudeTagUserId
            case "context_window": self = .contextWindow
            case "cost_type": self = .costType
            case "inference_geo": self = .inferenceGeo
            case "model": self = .model
            case "product": self = .product
            case "rbac_group_id": self = .rbacGroupId
            case "slack_channel_id": self = .slackChannelId
            case "speed": self = .speed
            case "token_type": self = .tokenType
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .claudeTagCategory: return "claude_tag_category"
            case .claudeTagUserId: return "claude_tag_user_id"
            case .contextWindow: return "context_window"
            case .costType: return "cost_type"
            case .inferenceGeo: return "inference_geo"
            case .model: return "model"
            case .product: return "product"
            case .rbacGroupId: return "rbac_group_id"
            case .slackChannelId: return "slack_channel_id"
            case .speed: return "speed"
            case .tokenType: return "token_type"
            case .unknown(let value): return value
            }
        }
    }

    public enum Order: OpenEnum, CaseIterable {
        case asc
        case desc
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Order] = [.asc, .desc]

        public init(rawValue: String) {
            switch rawValue {
            case "asc": self = .asc
            case "desc": self = .desc
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .asc: return "asc"
            case .desc: return "desc"
            case .unknown(let value): return value
            }
        }
    }

    public enum OrderBy: OpenEnum, CaseIterable {
        case amount
        case listAmount
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OrderBy] = [.amount, .listAmount]

        public init(rawValue: String) {
            switch rawValue {
            case "amount": self = .amount
            case "list_amount": self = .listAmount
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .amount: return "amount"
            case .listAmount: return "list_amount"
            case .unknown(let value): return value
            }
        }
    }

    public enum Speeds: OpenEnum, CaseIterable {
        case fast
        case standard
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Speeds] = [.fast, .standard]

        public init(rawValue: String) {
            switch rawValue {
            case "fast": self = .fast
            case "standard": self = .standard
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .fast: return "fast"
            case .standard: return "standard"
            case .unknown(let value): return value
            }
        }
    }
}
