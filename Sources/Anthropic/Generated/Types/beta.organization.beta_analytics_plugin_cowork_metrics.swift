// Transformed from `anthropic.types.beta.organization.beta_analytics_plugin_cowork_metrics` (beta_analytics_plugin_cowork_metrics.py).

import Foundation

/// Cowork activity metrics for a single plugin on a given day.
public struct BetaAnalyticsPluginCoworkMetrics: Codable, Hashable, Sendable {
    /// Number of distinct Cowork sessions in which the plugin was invoked.
    ///
    /// Null on aggregated rows where a distinct count cannot be computed.
    public var distinctSessionPluginUsedCount: Int?

    public init(distinctSessionPluginUsedCount: Int? = nil) {
        self.distinctSessionPluginUsedCount = distinctSessionPluginUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case distinctSessionPluginUsedCount = "distinct_session_plugin_used_count"
    }
}
