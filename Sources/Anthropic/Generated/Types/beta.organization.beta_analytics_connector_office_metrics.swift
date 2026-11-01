// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_office_metrics` (beta_analytics_connector_office_metrics.py).

import Foundation

/// Office Agent activity metrics for a single connector on a given day, broken out by Office product.
public struct BetaAnalyticsConnectorOfficeMetrics: Codable, Hashable, Sendable {
    /// Office Agent activity metrics for a single connector on a given day within one
    /// Office product.
    public var excel: BetaAnalyticsConnectorOfficeProductMetrics
    /// Office Agent activity metrics for a single connector on a given day within one
    /// Office product.
    public var outlook: BetaAnalyticsConnectorOfficeProductMetrics
    /// Office Agent activity metrics for a single connector on a given day within one
    /// Office product.
    public var powerpoint: BetaAnalyticsConnectorOfficeProductMetrics
    /// Office Agent activity metrics for a single connector on a given day within one
    /// Office product.
    public var word: BetaAnalyticsConnectorOfficeProductMetrics

    public init(excel: BetaAnalyticsConnectorOfficeProductMetrics, outlook: BetaAnalyticsConnectorOfficeProductMetrics, powerpoint: BetaAnalyticsConnectorOfficeProductMetrics, word: BetaAnalyticsConnectorOfficeProductMetrics) {
        self.excel = excel
        self.outlook = outlook
        self.powerpoint = powerpoint
        self.word = word
    }

    enum CodingKeys: String, CodingKey {
        case excel
        case outlook
        case powerpoint
        case word
    }
}
