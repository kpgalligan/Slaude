// Transformed from `anthropic.types.beta.organization.beta_analytics_science_metrics` (beta_analytics_science_metrics.py).

import Foundation

/// Claude Science activity metrics for a single user on a given day.
public struct BetaAnalyticsScienceMetrics: Codable, Hashable, Sendable {
    /// Number of delegations (handoffs to a specialized agent) in Claude Science
    /// sessions
    public var delegationCount: Int
    /// Number of distinct Claude Science sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionCount: Int?
    /// Number of messages sent in Claude Science sessions
    public var messageCount: Int
    /// Number of remote compute jobs launched from Claude Science sessions
    public var remoteComputeJobCount: Int
    /// Total number of skill invocations in Claude Science sessions
    public var skillsUsedCount: Int

    public init(delegationCount: Int, distinctSessionCount: Int? = nil, messageCount: Int, remoteComputeJobCount: Int, skillsUsedCount: Int) {
        self.delegationCount = delegationCount
        self.distinctSessionCount = distinctSessionCount
        self.messageCount = messageCount
        self.remoteComputeJobCount = remoteComputeJobCount
        self.skillsUsedCount = skillsUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case delegationCount = "delegation_count"
        case distinctSessionCount = "distinct_session_count"
        case messageCount = "message_count"
        case remoteComputeJobCount = "remote_compute_job_count"
        case skillsUsedCount = "skills_used_count"
    }
}
