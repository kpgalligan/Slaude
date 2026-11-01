// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_chat_cowork_unified_chat_metrics` (beta_analytics_skill_chat_cowork_unified_chat_metrics.py).

import Foundation

/// A skill's use in chat conversations recorded while members had
/// Chat and Cowork unified turned on.
public struct BetaAnalyticsSkillChatCoworkUnifiedChatMetrics: Codable, Hashable, Sendable {
    /// Same measure as `chat_metrics.distinct_conversation_skill_used_count`, for
    /// activity recorded while members had Chat and Cowork unified turned on.
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
