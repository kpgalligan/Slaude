// Transformed from `anthropic.types.beta.organization.beta_analytics_office_metrics` (beta_analytics_office_metrics.py).

import Foundation

/// Office Agent activity metrics for a single user on a given day, broken out by Office product.
public struct BetaAnalyticsOfficeMetrics: Codable, Hashable, Sendable {
    /// Office Agent activity metrics for a single user on a given day within one Office
    /// product.
    public var excel: BetaAnalyticsOfficeProductMetrics
    /// Office Agent activity metrics for a single user on a given day within one Office
    /// product.
    public var outlook: BetaAnalyticsOfficeProductMetrics
    /// Office Agent activity metrics for a single user on a given day within one Office
    /// product.
    public var powerpoint: BetaAnalyticsOfficeProductMetrics
    /// Office Agent activity metrics for a single user on a given day within one Office
    /// product.
    public var word: BetaAnalyticsOfficeProductMetrics

    public init(excel: BetaAnalyticsOfficeProductMetrics, outlook: BetaAnalyticsOfficeProductMetrics, powerpoint: BetaAnalyticsOfficeProductMetrics, word: BetaAnalyticsOfficeProductMetrics) {
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
