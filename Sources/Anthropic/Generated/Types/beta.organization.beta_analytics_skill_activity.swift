// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_activity` (beta_analytics_skill_activity.py).

import Foundation

/// Per-skill activity data for a given day.
public struct BetaAnalyticsSkillActivity: Codable, Hashable, Sendable {
    /// Claude.ai activity metrics for a single skill on a given day.
    public var chatMetrics: BetaAnalyticsSkillChatMetrics
    /// Claude Code activity metrics for a single skill on a given day.
    public var claudeCodeMetrics: BetaAnalyticsSkillClaudeCodeMetrics
    /// Cowork activity metrics for a single skill on a given day.
    public var coworkMetrics: BetaAnalyticsSkillCoworkMetrics
    /// Number of distinct users who used the skill on the requested day, or, in
    /// date-range mode, over the requested window — recomputed as an exact distinct
    /// count over the window's per-member daily rows, never a sum of per-day values. A
    /// skill counts as used only when it is explicitly activated — the model (or the
    /// user, via the skill's slash command) invokes it, reading its instructions into
    /// context as part of that activation. Skills that are merely installed or listed
    /// as available, or whose content reaches the context without an activation
    /// (preloaded, hook-injected, or read as a plain file), are not counted.
    public var distinctUserCount: Int
    /// Office Agent activity metrics for a single skill on a given day, broken out by
    /// Office product.
    public var officeMetrics: BetaAnalyticsSkillOfficeMetrics
    /// Name of the skill
    public var skillName: String
    /// List-price (rate-card) value of the member requests attributed to this skill, as
    /// a decimal string in the minor unit of `currency` (cents for USD), from Claude
    /// Code, Cowork, and Office Agent request-level attribution — the value of requests
    /// that involved the skill, not the skill's incremental cost. Unlike
    /// `estimated_overage_spend` this reflects usage value regardless of how it was
    /// funded — seat-covered usage counts — but it is undiscounted and does not tie to
    /// billed spend or the organization's spend reporting. claude.ai chat usage carries
    /// no request-level attribution and contributes nothing: the field is null on
    /// `chat` product rows and on `office_agent` product cuts dated before 2026-06-18
    /// (the Office Agent attribution data-start), and on ungrouped rows it covers the
    /// Claude Code + Cowork + Office Agent share only (null when no attributable usage
    /// exists). Also null under the same conditions as `estimated_overage_spend` (spend
    /// reporting not enabled for this organization, `office_agent` product cuts before
    /// the 2026-06-18 data-start). "0" means attributable usage existed but none was
    /// attributed to this skill. Addable across days: date-range rollup mode returns
    /// the window's sum. On `group_by[]` and `filter[]` shapes both amounts can total
    /// below the ungrouped value for the same skill over the same date or range: spend
    /// attributed to a member–skill pair with no counted usage on that day is excluded
    /// from those cuts.
    public var attributedListPrice: String?
    /// Skill use recorded while members had Chat and Cowork unified (Cowork's features
    /// inside claude.ai chat) turned on, split into chat conversations and Cowork
    /// sessions. A count is null in date-range mode where it cannot be computed.
    /// Omitted from the response on deployments that do not offer Chat and Cowork
    /// unified.
    public var chatCoworkUnifiedMetrics: BetaAnalyticsSkillActivity.ChatCoworkUnifiedMetrics?
    /// Currency for this row's monetary fields (`estimated_overage_spend` and
    /// `attributed_list_price`), as an uppercase ISO-4217 code. Always "USD" when
    /// either amount is populated; null whenever both amounts are null.
    public var currency: String?
    /// Distinct accounts that enabled this skill on the requested day (claude.ai only —
    /// the skill analog of plugin `install_count`). The count is org-wide: null when
    /// enable reporting is not enabled for this organization, or when the request
    /// scopes to `user_id` / `rbac_group_id` / `product` via `group_by[]` or `filter[]`
    /// (an org-wide count would be misleading on per-cut rows). A distinct count, not
    /// an event count: summing across days double-counts members who enable the skill
    /// on more than one day, so it is also null in date-range rollup mode
    /// (`starting_date`/`ending_date`).
    public var enableCount: Int?
    /// Estimated overage spend attributed to this skill, as a decimal string in the
    /// minor unit of `currency` (cents for USD; "1250" is $12.50, fractional cents
    /// possible) — an allocation of each member's daily post-discount, pre-credit
    /// metered overage spend (the same cost basis as the organization's spend reporting
    /// and the Cost & Usage API, so per-skill figures are directly comparable; spend
    /// with no skill attribution — including any member-day without skill invocations —
    /// is not represented, so skill rows sum to at most those totals) across the skills
    /// the member used. Overage only: usage covered by included seat allowances bills
    /// nothing and allocates $0 here — see `attributed_list_price` for the
    /// funding-independent usage-value companion. Claude Code, Cowork, and Office Agent
    /// spend use request-level skill attribution; claude.ai chat spend is approximated
    /// proportionally to skill-invoking messages. An estimate, not a billing number —
    /// and the cost of the requests/messages that involved the skill, not the skill's
    /// incremental cost (the same request would still have cost something without the
    /// skill active). "0" means no overage spend was attributed; null when spend
    /// reporting is not enabled for this organization, on `office_agent` product cuts
    /// dated before 2026-06-18 (the Office Agent attribution data-start). Addable
    /// across days: date-range rollup mode (`starting_date`/`ending_date`) returns the
    /// window's sum. With `group_by[]=user_id` each row carries the user's own
    /// attributed spend. On `group_by[]` and `filter[]` shapes both amounts can total
    /// below the ungrouped value for the same skill over the same date or range: spend
    /// attributed to a member–skill pair with no counted usage on that day is excluded
    /// from those cuts.
    public var estimatedOverageSpend: String?
    /// Total number of times this skill was invoked on the requested day (the skill
    /// analog of plugin `invocation_count`). Unlike `distinct_user_count` — which
    /// answers '# of users' — this is the true '# of uses'. A skill counts as used only
    /// when it is explicitly activated — the model (or the user, via the skill's slash
    /// command) invokes it, reading its instructions into context as part of that
    /// activation. Skills that are merely installed or listed as available, or whose
    /// content reaches the context without an activation (preloaded, hook-injected, or
    /// read as a plain file), are not counted. Null when invocation reporting is not
    /// enabled for this organization. Sum across a date range for total uses in the
    /// window — date-range rollup mode (`starting_date`/`ending_date`) returns this sum
    /// directly.
    public var invocationCount: Int?
    /// Product that produced this row's activity: one of `chat`, `claude_code`,
    /// `cowork`, `office_agent`, or `chat_cowork_unified` (Chat and Cowork unified).
    /// These are the canonical Cost & Usage product names; an `office_agent` row's
    /// per-surface breakdown is in its `office_metrics`. On `/plugins` only `cowork`,
    /// `claude_code` and `chat_cowork_unified` occur (the only surfaces with plugin
    /// attribution); on `/artifacts` only `chat`, `claude_code`, `cowork` and
    /// `chat_cowork_unified` occur (the surfaces that create artifacts);
    /// `/apps/chat/projects` does not support the product dimension (a `product` entry
    /// in `group_by[]` or `filter[]` there is rejected). Present only when the request
    /// grouped by `product`.
    public var product: String?
    /// Tagged RBAC group identifier (`rbac_group_...`), matching the spend-limits API
    /// spelling. Present only when the request grouped by `rbac_group_id`.
    public var rbacGroupID: String?
    /// Resolved RBAC group display name, alongside `rbac_group_id` when name resolution
    /// is available. Null if the group has been deleted or its name could not be
    /// resolved; `rbac_group_id` remains the stable key.
    public var rbacGroupName: String?
    /// Skill share status (claude.ai only): one of `private`, `organization`, or
    /// `public`. Null for skills used only in Claude Code or Office (no per-skill
    /// share-status concept) and when share-status reporting is not yet available for
    /// the organization. Filterable via `filter[]=share_status:{value}`.
    public var shareStatus: ShareStatus?
    /// Human-readable display name for rows whose `skill_name` is an opaque skill id
    /// (user/organization skill types and plugin-delivered skills, whose user-defined
    /// names usage reports generally withhold). Organization-shared skills and skills
    /// delivered by the organization's own plugins (its plugin marketplaces and its
    /// library) resolve; plugin skill names are shown without their 'plugin:' prefix.
    /// The literal 'unknown' bucket row gets a fixed 'Unknown skill' label. For a
    /// member's own skill (private or personal-plugin) it is null, except when the
    /// skill's owner used it from Claude Code or Cowork in the requested period: then
    /// it shows the name that client reported at the time. Apart from that, the names
    /// of members' own skills are not disclosed to analytics-key holders. Also null for
    /// Anthropic-provided plugin skills (not resolved), for an organization skill or
    /// plugin whose name can no longer be found (for example, one since deleted), when
    /// `skill_name` is already a display name, or when display-name resolution is not
    /// enabled for this organization.
    public var skillDisplayName: String?
    /// Tagged user identifier (e.g.
    ///
    /// `user_...`). Present only when the request grouped by `user_id`.
    public var userID: String?

    public init(chatMetrics: BetaAnalyticsSkillChatMetrics, claudeCodeMetrics: BetaAnalyticsSkillClaudeCodeMetrics, coworkMetrics: BetaAnalyticsSkillCoworkMetrics, distinctUserCount: Int, officeMetrics: BetaAnalyticsSkillOfficeMetrics, skillName: String, attributedListPrice: String? = nil, chatCoworkUnifiedMetrics: BetaAnalyticsSkillActivity.ChatCoworkUnifiedMetrics? = nil, currency: String? = nil, enableCount: Int? = nil, estimatedOverageSpend: String? = nil, invocationCount: Int? = nil, product: String? = nil, rbacGroupID: String? = nil, rbacGroupName: String? = nil, shareStatus: ShareStatus? = nil, skillDisplayName: String? = nil, userID: String? = nil) {
        self.chatMetrics = chatMetrics
        self.claudeCodeMetrics = claudeCodeMetrics
        self.coworkMetrics = coworkMetrics
        self.distinctUserCount = distinctUserCount
        self.officeMetrics = officeMetrics
        self.skillName = skillName
        self.attributedListPrice = attributedListPrice
        self.chatCoworkUnifiedMetrics = chatCoworkUnifiedMetrics
        self.currency = currency
        self.enableCount = enableCount
        self.estimatedOverageSpend = estimatedOverageSpend
        self.invocationCount = invocationCount
        self.product = product
        self.rbacGroupID = rbacGroupID
        self.rbacGroupName = rbacGroupName
        self.shareStatus = shareStatus
        self.skillDisplayName = skillDisplayName
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case chatMetrics = "chat_metrics"
        case claudeCodeMetrics = "claude_code_metrics"
        case coworkMetrics = "cowork_metrics"
        case distinctUserCount = "distinct_user_count"
        case officeMetrics = "office_metrics"
        case skillName = "skill_name"
        case attributedListPrice = "attributed_list_price"
        case chatCoworkUnifiedMetrics = "chat_cowork_unified_metrics"
        case currency
        case enableCount = "enable_count"
        case estimatedOverageSpend = "estimated_overage_spend"
        case invocationCount = "invocation_count"
        case product
        case rbacGroupID = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case shareStatus = "share_status"
        case skillDisplayName = "skill_display_name"
        case userID = "user_id"
    }

    public enum ShareStatus: OpenEnum, CaseIterable {
        case organization
        case `private`
        case `public`
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ShareStatus] = [.organization, .`private`, .`public`]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "private": self = .`private`
            case "public": self = .`public`
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .`private`: return "private"
            case .`public`: return "public"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaAnalyticsSkillActivity {

    /// Skill use recorded while members had Chat and Cowork unified (Cowork's features inside claude.ai chat) turned on, split into chat conversations and Cowork sessions. A count is null in date-range mode where it cannot be computed. Omitted from the response on deployments that do not offer Chat and Cowork unified.
    public struct ChatCoworkUnifiedMetrics: Codable, Hashable, Sendable {
        /// A skill's use in chat conversations recorded while members had Chat and Cowork
        /// unified turned on.
        public var chat: BetaAnalyticsSkillChatCoworkUnifiedChatMetrics
        /// A skill's use in Cowork sessions recorded while members had Chat and Cowork
        /// unified turned on.
        public var sessions: BetaAnalyticsSkillChatCoworkUnifiedSessionsMetrics

        public init(chat: BetaAnalyticsSkillChatCoworkUnifiedChatMetrics, sessions: BetaAnalyticsSkillChatCoworkUnifiedSessionsMetrics) {
            self.chat = chat
            self.sessions = sessions
        }

        enum CodingKeys: String, CodingKey {
            case chat
            case sessions
        }
    }
}
