// Transformed from `anthropic.types.beta.organization.beta_analytics_user_activity` (beta_analytics_user_activity.py).

import Foundation

/// Per-user activity data for a given day.
public struct BetaAnalyticsUserActivity: Codable, Hashable, Sendable {
    /// Claude.ai activity metrics for a single user on a given day.
    public var chatMetrics: BetaAnalyticsChatMetrics
    /// Claude Code activity metrics for a single user on a given day.
    public var claudeCodeMetrics: BetaAnalyticsClaudeCodeMetrics
    /// Cowork activity metrics for a single user on a given day.
    public var coworkMetrics: BetaAnalyticsCoworkMetrics
    /// Claude Design activity metrics for a single user on a given day.
    public var designMetrics: BetaAnalyticsDesignMetrics
    /// Office Agent activity metrics for a single user on a given day, broken out by
    /// Office product.
    public var officeMetrics: BetaAnalyticsOfficeMetrics
    /// Claude Science activity metrics for a single user on a given day.
    public var scienceMetrics: BetaAnalyticsScienceMetrics
    /// Number of web searches performed
    public var webSearchCount: Int
    /// Activity recorded while the member had Chat and Cowork unified (Cowork's
    /// features inside claude.ai chat) turned on, split into `chat` (chat activity) and
    /// `sessions` (Cowork activity). Omitted from the response on deployments that do
    /// not offer Chat and Cowork unified.
    public var chatCoworkUnifiedMetrics: BetaAnalyticsUserActivity.ChatCoworkUnifiedMetrics?
    /// Number of distinct active users represented by this row.
    ///
    /// Only set for grouped rollups (`group_by[]`); null for per-user rows. In
    /// date-range mode, recomputed as an exact distinct count of the group's active
    /// members over the requested window, never a sum of per-day values.
    public var distinctUserCount: Int?
    /// Most recent UTC day (YYYY-MM-DD) on which the user had any counted activity,
    /// within the requested window: equal to the requested `date` in single-day mode,
    /// and to the latest active day from `starting_date` (inclusive) to `ending_date`
    /// (exclusive) in date-range rollup mode — never a day earlier than the window
    /// start. On filtered requests (`filter[]`) only days matching the filter count:
    /// with `filter[]=rbac_group_id:{id}` it is the last day the user was active while
    /// a member of that group, consistent with the row's other metrics. On grouped
    /// (`group_by[]`) rows it is the latest day any member of the group was active (the
    /// requested `date` in single-day mode). Omitted from the response while
    /// last-activity reporting is not enabled for this organization.
    public var lastActivityDate: ISODate?
    /// Tagged RBAC group identifier (`rbac_group_...`), matching the spend-limits API
    /// spelling. Present only when the request grouped by `rbac_group_id`.
    public var rbacGroupID: String?
    /// Resolved RBAC group display name, alongside `rbac_group_id` when name resolution
    /// is available. Null if the group has been deleted or its name could not be
    /// resolved; `rbac_group_id` remains the stable key.
    public var rbacGroupName: String?
    /// The user this row describes. Null on rows aggregated across users.
    public var user: BetaAnalyticsUser?

    public init(chatMetrics: BetaAnalyticsChatMetrics, claudeCodeMetrics: BetaAnalyticsClaudeCodeMetrics, coworkMetrics: BetaAnalyticsCoworkMetrics, designMetrics: BetaAnalyticsDesignMetrics, officeMetrics: BetaAnalyticsOfficeMetrics, scienceMetrics: BetaAnalyticsScienceMetrics, webSearchCount: Int, chatCoworkUnifiedMetrics: BetaAnalyticsUserActivity.ChatCoworkUnifiedMetrics? = nil, distinctUserCount: Int? = nil, lastActivityDate: ISODate? = nil, rbacGroupID: String? = nil, rbacGroupName: String? = nil, user: BetaAnalyticsUser? = nil) {
        self.chatMetrics = chatMetrics
        self.claudeCodeMetrics = claudeCodeMetrics
        self.coworkMetrics = coworkMetrics
        self.designMetrics = designMetrics
        self.officeMetrics = officeMetrics
        self.scienceMetrics = scienceMetrics
        self.webSearchCount = webSearchCount
        self.chatCoworkUnifiedMetrics = chatCoworkUnifiedMetrics
        self.distinctUserCount = distinctUserCount
        self.lastActivityDate = lastActivityDate
        self.rbacGroupID = rbacGroupID
        self.rbacGroupName = rbacGroupName
        self.user = user
    }

    enum CodingKeys: String, CodingKey {
        case chatMetrics = "chat_metrics"
        case claudeCodeMetrics = "claude_code_metrics"
        case coworkMetrics = "cowork_metrics"
        case designMetrics = "design_metrics"
        case officeMetrics = "office_metrics"
        case scienceMetrics = "science_metrics"
        case webSearchCount = "web_search_count"
        case chatCoworkUnifiedMetrics = "chat_cowork_unified_metrics"
        case distinctUserCount = "distinct_user_count"
        case lastActivityDate = "last_activity_date"
        case rbacGroupID = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case user
    }
}

extension BetaAnalyticsUserActivity {

    /// Activity recorded while the member had Chat and Cowork unified (Cowork's features inside claude.ai chat) turned on, split into `chat` (chat activity) and `sessions` (Cowork activity). Omitted from the response on deployments that do not offer Chat and Cowork unified.
    public struct ChatCoworkUnifiedMetrics: Codable, Hashable, Sendable {
        /// Chat activity recorded while members had Chat and Cowork unified turned on.
        public var chat: BetaAnalyticsChatCoworkUnifiedChatMetrics
        /// Cowork session activity recorded while members had Chat and Cowork unified
        /// turned on.
        public var sessions: BetaAnalyticsChatCoworkUnifiedSessionsMetrics

        public init(chat: BetaAnalyticsChatCoworkUnifiedChatMetrics, sessions: BetaAnalyticsChatCoworkUnifiedSessionsMetrics) {
            self.chat = chat
            self.sessions = sessions
        }

        enum CodingKeys: String, CodingKey {
            case chat
            case sessions
        }
    }
}
