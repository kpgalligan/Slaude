// Transformed from `anthropic.types.beta.organization.beta_analytics_core_code_metrics` (beta_analytics_core_code_metrics.py).

import Foundation

/// Core Claude Code activity metrics for a single user on a given day.
public struct BetaAnalyticsCoreCodeMetrics: Codable, Hashable, Sendable {
    /// Number of artifacts created in Claude Code sessions: an artifact counts once, on
    /// the day a session first saves it. Counted from 2026-08-17; 0 on earlier days.
    /// Exact in date-range mode: a creation belongs to exactly one day, so the per-day
    /// counts never overlap and their sum over the window is the exact count of
    /// distinct creations in it.
    public var artifactsCreatedCount: Int
    /// Number of commits made via Claude Code
    public var commitCount: Int
    /// Number of distinct Claude Code sessions.
    ///
    /// On aggregated rows and in date-range mode: summed per-day distinct counts. A
    /// session essentially never spans a UTC day, so the sum is in practice the true
    /// distinct count.
    public var distinctSessionCount: Int?
    /// Lines of code added and removed via Claude Code.
    public var linesOfCode: BetaAnalyticsLinesOfCode
    /// Number of pull requests created via Claude Code
    public var pullRequestCount: Int

    public init(artifactsCreatedCount: Int, commitCount: Int, distinctSessionCount: Int? = nil, linesOfCode: BetaAnalyticsLinesOfCode, pullRequestCount: Int) {
        self.artifactsCreatedCount = artifactsCreatedCount
        self.commitCount = commitCount
        self.distinctSessionCount = distinctSessionCount
        self.linesOfCode = linesOfCode
        self.pullRequestCount = pullRequestCount
    }

    enum CodingKeys: String, CodingKey {
        case artifactsCreatedCount = "artifacts_created_count"
        case commitCount = "commit_count"
        case distinctSessionCount = "distinct_session_count"
        case linesOfCode = "lines_of_code"
        case pullRequestCount = "pull_request_count"
    }
}
