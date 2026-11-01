// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_chat_metrics` (beta_analytics_connector_chat_metrics.py).

import Foundation

/// Claude.ai activity metrics for a single connector on a given day.
public struct BetaAnalyticsConnectorChatMetrics: Codable, Hashable, Sendable {
    /// Number of distinct conversations in which the connector was used.
    ///
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
