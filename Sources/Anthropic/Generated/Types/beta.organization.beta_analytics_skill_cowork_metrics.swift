// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_cowork_metrics` (beta_analytics_skill_cowork_metrics.py).

import Foundation

/// Cowork activity metrics for a single skill on a given day.
public struct BetaAnalyticsSkillCoworkMetrics: Codable, Hashable, Sendable {
    /// Number of distinct Cowork sessions in which the skill was used.
    ///
    /// A skill counts as used only when it is explicitly activated — the model (or the
    /// user, via the skill's slash command) invokes it, reading its instructions into
    /// context as part of that activation. Skills that are merely installed or listed
    /// as available, or whose content reaches the context without an activation
    /// (preloaded, hook-injected, or read as a plain file), are not counted.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionSkillUsedCount: Int?

    public init(distinctSessionSkillUsedCount: Int? = nil) {
        self.distinctSessionSkillUsedCount = distinctSessionSkillUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctSessionSkillUsedCount = "distinct_session_skill_used_count"
    }
}
