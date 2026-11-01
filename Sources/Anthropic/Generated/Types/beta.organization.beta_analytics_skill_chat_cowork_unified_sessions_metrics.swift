// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_chat_cowork_unified_sessions_metrics` (beta_analytics_skill_chat_cowork_unified_sessions_metrics.py).

import Foundation

/// A skill's use in Cowork sessions recorded while members had Chat
/// and Cowork unified turned on.
public struct BetaAnalyticsSkillChatCoworkUnifiedSessionsMetrics: Codable, Hashable, Sendable {
    /// Same measure as `cowork_metrics.distinct_session_skill_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctSessionSkillUsedCount: Int?

    public init(distinctSessionSkillUsedCount: Int? = nil) {
        self.distinctSessionSkillUsedCount = distinctSessionSkillUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctSessionSkillUsedCount = "distinct_session_skill_used_count"
    }
}
