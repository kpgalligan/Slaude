// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_chat_metrics` (beta_analytics_skill_chat_metrics.py).

import Foundation

/// Claude.ai activity metrics for a single skill on a given day.
public struct BetaAnalyticsSkillChatMetrics: Codable, Hashable, Sendable {
    /// Number of distinct conversations in which the skill was used.
    ///
    /// A skill counts as used only when it is explicitly activated — the model (or the
    /// user, via the skill's slash command) invokes it, reading its instructions into
    /// context as part of that activation. Skills that are merely installed or listed
    /// as available, or whose content reaches the context without an activation
    /// (preloaded, hook-injected, or read as a plain file), are not counted.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctConversationSkillUsedCount: Int?

    public init(distinctConversationSkillUsedCount: Int? = nil) {
        self.distinctConversationSkillUsedCount = distinctConversationSkillUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctConversationSkillUsedCount = "distinct_conversation_skill_used_count"
    }
}
