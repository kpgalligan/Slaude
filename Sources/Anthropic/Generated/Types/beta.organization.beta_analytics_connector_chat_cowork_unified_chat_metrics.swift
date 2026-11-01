// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_chat_cowork_unified_chat_metrics` (beta_analytics_connector_chat_cowork_unified_chat_metrics.py).

import Foundation

/// A connector's use in chat conversations recorded while members had
/// Chat and Cowork unified turned on.
public struct BetaAnalyticsConnectorChatCoworkUnifiedChatMetrics: Codable, Hashable, Sendable {
    /// Same measure as `chat_metrics.distinct_conversation_connector_used_count`, for
    /// activity recorded while members had Chat and Cowork unified turned on.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctConversationConnectorUsedCount: Int?

    public init(distinctConversationConnectorUsedCount: Int? = nil) {
        self.distinctConversationConnectorUsedCount = distinctConversationConnectorUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctConversationConnectorUsedCount = "distinct_conversation_connector_used_count"
    }
}
