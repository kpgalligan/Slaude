// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_cowork_metrics` (beta_analytics_connector_cowork_metrics.py).

import Foundation

/// Cowork activity metrics for a single connector on a given day.
public struct BetaAnalyticsConnectorCoworkMetrics: Codable, Hashable, Sendable {
    /// Number of distinct Cowork sessions in which the connector was used.
    ///
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
