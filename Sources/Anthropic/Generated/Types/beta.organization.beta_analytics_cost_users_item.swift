// Transformed from `anthropic.types.beta.organization.beta_analytics_cost_users_item` (beta_analytics_cost_users_item.py).

import Foundation

public struct BetaAnalyticsCostUsersItem: Codable, Hashable, Sendable {
    /// The user this row's usage or cost is attributed to. Always a `user_actor`.
    public var actor: BetaAnalyticsUserActor
    /// Amount (post-discount, pre-credit) in fractional cents (minor units).
    public var amount: String
    /// Claude Tag (Claude in Slack) spend category: `engaged` (a person addressed
    /// Claude in a channel or thread), `proactive` (Claude responded without being
    /// addressed), `scheduled` (a scheduled routine ran), `monitoring` (Claude watching
    /// a channel it was asked to monitor), or `dm` (direct messages with Claude).
    /// Populated only when `claude_tag_category` is in `group_by[]`; null for usage
    /// that is not Claude Tag. Direct-message usage is billed to the individual user
    /// and is reported under that user's product, not under `claude-tag`. New
    /// categories may be added over time.
    public var claudeTagCategory: BetaAnalyticsClaudeTagCategory?
    /// Slack user ID (for example `U0123ABCDEF`) of the member the Claude Tag (Claude
    /// in Slack) usage is attributed to, not a claude.ai user ID. Populated only when
    /// `claude_tag_user_id` is in `group_by[]`; null for usage that is not Claude Tag
    /// and for Claude Tag usage that is not attributed to a single user (for example
    /// `monitoring`, and `proactive` usage Claude initiated), so per-user rows can sum
    /// to less than the Claude Tag total. Cannot be combined with
    /// `group_by[]=rbac_group_id` or the `rbac_group_ids[]` filter.
    public var claudeTagUserId: String?
    /// Context-window pricing tier of the usage or cost.
    ///
    /// Null unless `context_window` is in `group_by[]`; it can also be null on grouped
    /// rows with no context-window tier, such as code execution.
    public var contextWindow: BetaAnalyticsContextWindow?
    /// Cost component breakdown; null when returning the combined total.
    public var costType: BetaAnalyticsCostType?
    /// Currency code for the cost amount. Currently always `"USD"`.
    public var currency: String
    /// End of the row's UTC time bucket (exclusive), as an RFC 3339 timestamp; equal to
    /// `starting_at` plus one `bucket_width`. Null unless `bucket_width` is set.
    public var endingAt: Date?
    /// Inference region of the usage or cost.
    ///
    /// Null unless `inference_geo` is in `group_by[]`; it can also be null on grouped
    /// rows where the region is not set (the rows that `inference_geos[]=not_available`
    /// matches).
    public var inferenceGeo: InferenceGeo?
    /// List-price amount (pre-discount) in fractional cents.
    public var listAmount: String
    /// Model that produced the usage or cost, as a model name in the form the
    /// `models[]` filter accepts (for example, `claude-opus-5-5`). Null unless `model`
    /// is in `group_by[]`; it can also be null on grouped rows whose usage or cost is
    /// not attributed to a specific model, such as code execution.
    public var model: String?
    /// Product surface that produced the usage or cost.
    ///
    /// Null unless product is in `group_by[]`; it can also be null on grouped rows
    /// whose usage cannot be attributed to a known surface. Values include `chat`,
    /// `claude_code`, `cowork`, `office_agent`, `claude_in_chrome`, `claude_design`,
    /// `claude-tag`, and `chat_cowork_unified`. `claude-tag` is Claude Tag, the Claude
    /// product in Slack. `chat_cowork_unified` is Chat and Cowork unified, Cowork's
    /// features inside claude.ai chat: chat and Cowork usage by a member who has it
    /// turned on is reported under this value instead of `chat` or `cowork`. It is
    /// accepted as a filter only on deployments that offer Chat and Cowork unified.
    /// Some unattributed usage is reported as "other".
    public var product: String?
    /// RBAC group (team) the usage is attributed to, in the public tagged
    /// `rbac_group_...` spelling — the same spelling the activity resources use for
    /// this key, so the same team has one id across resources and it round-trips as an
    /// `rbac_group_ids[]` filter value. Populated only when `rbac_group_id` is in
    /// `group_by[]`. Any-membership semantics: a user in several groups contributes
    /// their full usage to each of those groups' rows, so the named-group rows overlap
    /// and their sum can exceed the org total. A null value is the single unassigned
    /// row: users in no group on that (UTC) day. For the true org total, run the same
    /// query without `group_by[]`.
    public var rbacGroupId: String?
    /// Number of API requests in this row's scope.
    ///
    /// Null when `group_by` includes `cost_type` or `token_type` (the count has no
    /// per-component attribution; read it from the ungrouped response). For sandbox /
    /// code-execution events, this counts execution spans rather than HTTP requests
    /// (these rows surface with `product: null`).
    public var requests: Int?
    /// Slack channel the usage originated from.
    ///
    /// Populated only when `slack_channel_id` is in `group_by[]`; null for usage
    /// outside Slack (and for rows recorded before channel attribution was enabled).
    public var slackChannelId: String?
    /// Inference speed mode of the usage or cost: `fast` or `standard`.
    ///
    /// Null unless `speed` is in `group_by[]`.
    public var speed: Speed?
    /// Start of the row's UTC time bucket (inclusive), as an RFC 3339 timestamp.
    ///
    /// Null unless `bucket_width` is set; without `bucket_width`, each row aggregates
    /// the full requested range.
    public var startingAt: Date?
    /// Token type when `cost_type` is `tokens`; null otherwise.
    public var tokenType: BetaAnalyticsTokenType?

    public init(actor: BetaAnalyticsUserActor, amount: String, claudeTagCategory: BetaAnalyticsClaudeTagCategory? = nil, claudeTagUserId: String? = nil, contextWindow: BetaAnalyticsContextWindow? = nil, costType: BetaAnalyticsCostType? = nil, currency: String, endingAt: Date? = nil, inferenceGeo: InferenceGeo? = nil, listAmount: String, model: String? = nil, product: String? = nil, rbacGroupId: String? = nil, requests: Int? = nil, slackChannelId: String? = nil, speed: Speed? = nil, startingAt: Date? = nil, tokenType: BetaAnalyticsTokenType? = nil) {
        self.actor = actor
        self.amount = amount
        self.claudeTagCategory = claudeTagCategory
        self.claudeTagUserId = claudeTagUserId
        self.contextWindow = contextWindow
        self.costType = costType
        self.currency = currency
        self.endingAt = endingAt
        self.inferenceGeo = inferenceGeo
        self.listAmount = listAmount
        self.model = model
        self.product = product
        self.rbacGroupId = rbacGroupId
        self.requests = requests
        self.slackChannelId = slackChannelId
        self.speed = speed
        self.startingAt = startingAt
        self.tokenType = tokenType
    }

    enum CodingKeys: String, CodingKey {
        case actor
        case amount
        case claudeTagCategory = "claude_tag_category"
        case claudeTagUserId = "claude_tag_user_id"
        case contextWindow = "context_window"
        case costType = "cost_type"
        case currency
        case endingAt = "ending_at"
        case inferenceGeo = "inference_geo"
        case listAmount = "list_amount"
        case model
        case product
        case rbacGroupId = "rbac_group_id"
        case requests
        case slackChannelId = "slack_channel_id"
        case speed
        case startingAt = "starting_at"
        case tokenType = "token_type"
    }

    public enum InferenceGeo: OpenEnum, CaseIterable {
        case global
        case us
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [InferenceGeo] = [.global, .us]

        public init(rawValue: String) {
            switch rawValue {
            case "global": self = .global
            case "us": self = .us
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .global: return "global"
            case .us: return "us"
            case .unknown(let value): return value
            }
        }
    }

    public enum Speed: OpenEnum, CaseIterable {
        case fast
        case standard
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Speed] = [.fast, .standard]

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
