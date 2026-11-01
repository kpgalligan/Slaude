// Transformed from `anthropic.types.beta.organization.beta_analytics_single_day_activity_summary` (beta_analytics_single_day_activity_summary.py).

import Foundation

/// Per-day entry in the /summaries response.
public struct BetaAnalyticsSingleDayActivitySummary: Codable, Hashable, Sendable {
    /// Number of seats currently assigned to members.
    ///
    /// Null when the response is scoped to an RBAC group — seat assignment is org-wide
    /// and has no per-group analogue.
    public var assignedSeatCount: Int?
    /// Number of users with Cowork activity on the requested day
    public var coworkDailyActiveUserCount: Int
    /// Number of users with Cowork activity in the 30-day rolling window
    public var coworkMonthlyActiveUserCount: Int
    /// Number of users with Cowork activity in the 7-day rolling window
    public var coworkWeeklyActiveUserCount: Int
    /// Number of users with token consumption on the requested day
    public var dailyActiveUserCount: Int
    /// Percentage of assigned seats with activity on the requested day
    /// (`DAU / assigned_seat_count * 100`). Null when the response is scoped to an RBAC
    /// group.
    public var dailyAdoptionRate: Double?
    /// End of the aggregation period (exclusive), UTC midnight in RFC 3339 format (e.g.
    ///
    /// `2026-01-16T00:00:00Z`).
    public var endingAt: Date
    /// Number of users with token consumption in the 30-day rolling window
    public var monthlyActiveUserCount: Int
    /// Percentage of assigned seats with activity in the 30-day rolling window
    /// (`MAU / assigned_seat_count * 100`). Null when the response is scoped to an RBAC
    /// group.
    public var monthlyAdoptionRate: Double?
    /// Number of pending invitations to join the organization.
    ///
    /// Null when the response is scoped to an RBAC group.
    public var pendingInviteCount: Int?
    /// Start of the aggregation period (inclusive), UTC midnight in RFC 3339 format
    /// (e.g. `2026-01-15T00:00:00Z`).
    public var startingAt: Date
    /// Number of users with token consumption in the 7-day rolling window
    public var weeklyActiveUserCount: Int
    /// Percentage of assigned seats with activity in the 7-day rolling window
    /// (`WAU / assigned_seat_count * 100`). Null when the response is scoped to an RBAC
    /// group.
    public var weeklyAdoptionRate: Double?
    /// Number of users with activity in Chat and Cowork unified on the requested day.
    ///
    /// Omitted from the response on deployments that do not offer Chat and Cowork
    /// unified.
    public var chatCoworkUnifiedDailyActiveUserCount: Int?
    /// Number of users with activity in Chat and Cowork unified in the 28-day rolling
    /// window (30 days when the request filters by `rbac_group_id`). Omitted from the
    /// response on deployments that do not offer Chat and Cowork unified.
    public var chatCoworkUnifiedMonthlyActiveUserCount: Int?
    /// Number of users with activity in Chat and Cowork unified in the 7-day rolling
    /// window. Omitted from the response on deployments that do not offer Chat and
    /// Cowork unified.
    public var chatCoworkUnifiedWeeklyActiveUserCount: Int?
    /// Number of users with claude.ai (chat) activity on the requested day.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var chatDailyActiveUserCount: Int?
    /// Number of users with claude.ai (chat) activity in the 30-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var chatMonthlyActiveUserCount: Int?
    /// Number of users with claude.ai (chat) activity in the 7-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var chatWeeklyActiveUserCount: Int?
    /// Number of users with Claude Code activity on the requested day.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeCodeDailyActiveUserCount: Int?
    /// Number of users with Claude Code activity in the 30-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeCodeMonthlyActiveUserCount: Int?
    /// Number of users with Claude Code activity in the 7-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeCodeWeeklyActiveUserCount: Int?
    /// Number of users with Claude Design activity on the requested day.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeDesignDailyActiveUserCount: Int?
    /// Number of users with Claude Design activity in the 30-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeDesignMonthlyActiveUserCount: Int?
    /// Number of users with Claude Design activity in the 7-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var claudeDesignWeeklyActiveUserCount: Int?
    /// Number of users with Claude in Office activity on the requested day.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var officeAgentDailyActiveUserCount: Int?
    /// Number of users with Claude in Office activity in the 30-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var officeAgentMonthlyActiveUserCount: Int?
    /// Number of users with Claude in Office activity in the 7-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var officeAgentWeeklyActiveUserCount: Int?
    /// Number of users with Claude Science activity on the requested day.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var scienceDailyActiveUserCount: Int?
    /// Number of users with a Claude Science seat entitlement (per-seat RBAC) at the
    /// time of the daily snapshot. The funnel top; independent of the org-level Claude
    /// Science toggle. Null when the response is scoped to an RBAC group — entitlement
    /// is org-wide and has no per-group analogue. Omitted from the response while the
    /// per-product breakdown is not enabled for this organization.
    public var scienceEntitledUserCount: Int?
    /// Number of users with Claude Science activity in the 30-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var scienceMonthlyActiveUserCount: Int?
    /// Number of users with Claude Science activity in the 7-day rolling window.
    ///
    /// Omitted from the response while the per-product breakdown is not enabled for
    /// this organization.
    public var scienceWeeklyActiveUserCount: Int?

    public init(assignedSeatCount: Int? = nil, coworkDailyActiveUserCount: Int, coworkMonthlyActiveUserCount: Int, coworkWeeklyActiveUserCount: Int, dailyActiveUserCount: Int, dailyAdoptionRate: Double? = nil, endingAt: Date, monthlyActiveUserCount: Int, monthlyAdoptionRate: Double? = nil, pendingInviteCount: Int? = nil, startingAt: Date, weeklyActiveUserCount: Int, weeklyAdoptionRate: Double? = nil, chatCoworkUnifiedDailyActiveUserCount: Int? = nil, chatCoworkUnifiedMonthlyActiveUserCount: Int? = nil, chatCoworkUnifiedWeeklyActiveUserCount: Int? = nil, chatDailyActiveUserCount: Int? = nil, chatMonthlyActiveUserCount: Int? = nil, chatWeeklyActiveUserCount: Int? = nil, claudeCodeDailyActiveUserCount: Int? = nil, claudeCodeMonthlyActiveUserCount: Int? = nil, claudeCodeWeeklyActiveUserCount: Int? = nil, claudeDesignDailyActiveUserCount: Int? = nil, claudeDesignMonthlyActiveUserCount: Int? = nil, claudeDesignWeeklyActiveUserCount: Int? = nil, officeAgentDailyActiveUserCount: Int? = nil, officeAgentMonthlyActiveUserCount: Int? = nil, officeAgentWeeklyActiveUserCount: Int? = nil, scienceDailyActiveUserCount: Int? = nil, scienceEntitledUserCount: Int? = nil, scienceMonthlyActiveUserCount: Int? = nil, scienceWeeklyActiveUserCount: Int? = nil) {
        self.assignedSeatCount = assignedSeatCount
        self.coworkDailyActiveUserCount = coworkDailyActiveUserCount
        self.coworkMonthlyActiveUserCount = coworkMonthlyActiveUserCount
        self.coworkWeeklyActiveUserCount = coworkWeeklyActiveUserCount
        self.dailyActiveUserCount = dailyActiveUserCount
        self.dailyAdoptionRate = dailyAdoptionRate
        self.endingAt = endingAt
        self.monthlyActiveUserCount = monthlyActiveUserCount
        self.monthlyAdoptionRate = monthlyAdoptionRate
        self.pendingInviteCount = pendingInviteCount
        self.startingAt = startingAt
        self.weeklyActiveUserCount = weeklyActiveUserCount
        self.weeklyAdoptionRate = weeklyAdoptionRate
        self.chatCoworkUnifiedDailyActiveUserCount = chatCoworkUnifiedDailyActiveUserCount
        self.chatCoworkUnifiedMonthlyActiveUserCount = chatCoworkUnifiedMonthlyActiveUserCount
        self.chatCoworkUnifiedWeeklyActiveUserCount = chatCoworkUnifiedWeeklyActiveUserCount
        self.chatDailyActiveUserCount = chatDailyActiveUserCount
        self.chatMonthlyActiveUserCount = chatMonthlyActiveUserCount
        self.chatWeeklyActiveUserCount = chatWeeklyActiveUserCount
        self.claudeCodeDailyActiveUserCount = claudeCodeDailyActiveUserCount
        self.claudeCodeMonthlyActiveUserCount = claudeCodeMonthlyActiveUserCount
        self.claudeCodeWeeklyActiveUserCount = claudeCodeWeeklyActiveUserCount
        self.claudeDesignDailyActiveUserCount = claudeDesignDailyActiveUserCount
        self.claudeDesignMonthlyActiveUserCount = claudeDesignMonthlyActiveUserCount
        self.claudeDesignWeeklyActiveUserCount = claudeDesignWeeklyActiveUserCount
        self.officeAgentDailyActiveUserCount = officeAgentDailyActiveUserCount
        self.officeAgentMonthlyActiveUserCount = officeAgentMonthlyActiveUserCount
        self.officeAgentWeeklyActiveUserCount = officeAgentWeeklyActiveUserCount
        self.scienceDailyActiveUserCount = scienceDailyActiveUserCount
        self.scienceEntitledUserCount = scienceEntitledUserCount
        self.scienceMonthlyActiveUserCount = scienceMonthlyActiveUserCount
        self.scienceWeeklyActiveUserCount = scienceWeeklyActiveUserCount
    }

    enum CodingKeys: String, CodingKey {
        case assignedSeatCount = "assigned_seat_count"
        case coworkDailyActiveUserCount = "cowork_daily_active_user_count"
        case coworkMonthlyActiveUserCount = "cowork_monthly_active_user_count"
        case coworkWeeklyActiveUserCount = "cowork_weekly_active_user_count"
        case dailyActiveUserCount = "daily_active_user_count"
        case dailyAdoptionRate = "daily_adoption_rate"
        case endingAt = "ending_at"
        case monthlyActiveUserCount = "monthly_active_user_count"
        case monthlyAdoptionRate = "monthly_adoption_rate"
        case pendingInviteCount = "pending_invite_count"
        case startingAt = "starting_at"
        case weeklyActiveUserCount = "weekly_active_user_count"
        case weeklyAdoptionRate = "weekly_adoption_rate"
        case chatCoworkUnifiedDailyActiveUserCount = "chat_cowork_unified_daily_active_user_count"
        case chatCoworkUnifiedMonthlyActiveUserCount = "chat_cowork_unified_monthly_active_user_count"
        case chatCoworkUnifiedWeeklyActiveUserCount = "chat_cowork_unified_weekly_active_user_count"
        case chatDailyActiveUserCount = "chat_daily_active_user_count"
        case chatMonthlyActiveUserCount = "chat_monthly_active_user_count"
        case chatWeeklyActiveUserCount = "chat_weekly_active_user_count"
        case claudeCodeDailyActiveUserCount = "claude_code_daily_active_user_count"
        case claudeCodeMonthlyActiveUserCount = "claude_code_monthly_active_user_count"
        case claudeCodeWeeklyActiveUserCount = "claude_code_weekly_active_user_count"
        case claudeDesignDailyActiveUserCount = "claude_design_daily_active_user_count"
        case claudeDesignMonthlyActiveUserCount = "claude_design_monthly_active_user_count"
        case claudeDesignWeeklyActiveUserCount = "claude_design_weekly_active_user_count"
        case officeAgentDailyActiveUserCount = "office_agent_daily_active_user_count"
        case officeAgentMonthlyActiveUserCount = "office_agent_monthly_active_user_count"
        case officeAgentWeeklyActiveUserCount = "office_agent_weekly_active_user_count"
        case scienceDailyActiveUserCount = "science_daily_active_user_count"
        case scienceEntitledUserCount = "science_entitled_user_count"
        case scienceMonthlyActiveUserCount = "science_monthly_active_user_count"
        case scienceWeeklyActiveUserCount = "science_weekly_active_user_count"
    }
}
