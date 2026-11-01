// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_chat_cowork_unified_sessions_metrics` (beta_analytics_connector_chat_cowork_unified_sessions_metrics.py).

import Foundation

/// A connector's use in Cowork sessions recorded while members had
/// Chat and Cowork unified turned on.
public struct BetaAnalyticsConnectorChatCoworkUnifiedSessionsMetrics: Codable, Hashable, Sendable {
    /// Same measure as `cowork_metrics.distinct_session_connector_used_count`, for
    /// activity recorded while members had Chat and Cowork unified turned on.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionConnectorUsedCount: Int?

    public init(distinctSessionConnectorUsedCount: Int? = nil) {
        self.distinctSessionConnectorUsedCount = distinctSessionConnectorUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctSessionConnectorUsedCount = "distinct_session_connector_used_count"
    }
}
