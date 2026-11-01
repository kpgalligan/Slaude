// Transformed from `anthropic.types.beta.organization.analytics.cost_report_list_params` (cost_report_list_params.py).

import Foundation

public struct CostReportListParams: Codable, Hashable, Sendable {
    /// Start of range, inclusive.
    ///
    /// RFC 3339 tz-aware. Must be within the last 365 days and no earlier than
    /// 2026-01-01T00:00:00Z.
    public var startingAt: StartingAt
    /// Time bucket granularity.
    public var bucketWidth: BucketWidth?
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
    /// Dimensions to break each time bucket out by.
    ///
    /// Defaults to no grouping (one total per bucket). Each bucket reports at most its
    /// top 100 groups; a group beyond that cap has no row in that bucket (there is no
    /// remainder row), so grouped buckets are not exhaustive when a dimension has more
    /// than 100 distinct values.
    public var groupBy: [GroupBy]??
    /// Filter to specific inference regions.
    ///
    /// `not_available` matches rows where the region is unset. Use
    /// `group_by[]=inference_geo` to break out per-region values.
    public var inferenceGeos: [BetaAnalyticsInferenceGeoFilter]??
    /// Maximum number of time buckets per page.
    ///
    /// Defaults and caps vary by `bucket_width` (`1d`: default 7, max 31; `1h`: default
    /// 24, max 168; `1m`: default 60, max 256).
    public var limit: Int??
    /// Models to include.
    ///
    /// Defaults to all models. Use `group_by[]=model` to break out per-model values.
    public var models: [String]??
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// Product surfaces to include.
    ///
    /// Defaults to all products. Use `group_by[]=product` to break out per-product
    /// values.
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

    public init(startingAt: StartingAt, bucketWidth: BucketWidth? = nil, claudeTagCategories: [BetaAnalyticsClaudeTagCategory]?? = nil, claudeTagUserIDs: [String]?? = nil, contextWindows: [BetaAnalyticsContextWindow]?? = nil, endingAt: EndingAt?? = nil, groupBy: [GroupBy]?? = nil, inferenceGeos: [BetaAnalyticsInferenceGeoFilter]?? = nil, limit: Int?? = nil, models: [String]?? = nil, page: String?? = nil, products: [BetaAnalyticsProductFilter]?? = nil, rbacGroupIDs: [String]?? = nil, slackChannelIDs: [String]?? = nil, speeds: [Speeds]?? = nil, userIDs: [String]?? = nil) {
        self.startingAt = startingAt
        self.bucketWidth = bucketWidth
        self.claudeTagCategories = claudeTagCategories
        self.claudeTagUserIDs = claudeTagUserIDs
        self.contextWindows = contextWindows
        self.endingAt = endingAt
        self.groupBy = groupBy
        self.inferenceGeos = inferenceGeos
        self.limit = limit
        self.models = models
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
        case groupBy = "group_by"
        case inferenceGeos = "inference_geos"
        case limit
        case models
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
