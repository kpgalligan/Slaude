// Transformed from `anthropic.types.beta.organization.beta_analytics_design_metrics` (beta_analytics_design_metrics.py).

import Foundation

/// Claude Design activity metrics for a single user on a given day.
public struct BetaAnalyticsDesignMetrics: Codable, Hashable, Sendable {
    /// Number of distinct Claude Design projects created.
    ///
    /// Exact in date-range mode: a creation belongs to exactly one day, so the per-day
    /// counts never overlap and their sum over the window is the exact count of
    /// distinct creations in it.
    public var distinctProjectsCreatedCount: Int
    /// Number of distinct Claude Design projects the user worked in.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctProjectsUsedCount: Int?
    /// Number of distinct Claude Design sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionCount: Int?
    /// Number of messages sent in Claude Design sessions
    public var messageCount: Int

    public init(distinctProjectsCreatedCount: Int, distinctProjectsUsedCount: Int? = nil, distinctSessionCount: Int? = nil, messageCount: Int) {
        self.distinctProjectsCreatedCount = distinctProjectsCreatedCount
        self.distinctProjectsUsedCount = distinctProjectsUsedCount
        self.distinctSessionCount = distinctSessionCount
        self.messageCount = messageCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctProjectsCreatedCount = "distinct_projects_created_count"
        case distinctProjectsUsedCount = "distinct_projects_used_count"
        case distinctSessionCount = "distinct_session_count"
        case messageCount = "message_count"
    }
}
