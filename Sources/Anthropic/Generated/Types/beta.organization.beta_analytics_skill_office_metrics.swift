// Transformed from `anthropic.types.beta.organization.beta_analytics_skill_office_metrics` (beta_analytics_skill_office_metrics.py).

import Foundation

/// Office Agent activity metrics for a single skill on a given day, broken out by Office product.
public struct BetaAnalyticsSkillOfficeMetrics: Codable, Hashable, Sendable {
    /// Office Agent activity metrics for a single skill on a given day within one
    /// Office product.
    public var excel: BetaAnalyticsSkillOfficeProductMetrics
    /// Office Agent activity metrics for a single skill on a given day within one
    /// Office product.
    public var outlook: BetaAnalyticsSkillOfficeProductMetrics
    /// Office Agent activity metrics for a single skill on a given day within one
    /// Office product.
    public var powerpoint: BetaAnalyticsSkillOfficeProductMetrics
    /// Office Agent activity metrics for a single skill on a given day within one
    /// Office product.
    public var word: BetaAnalyticsSkillOfficeProductMetrics

    public init(excel: BetaAnalyticsSkillOfficeProductMetrics, outlook: BetaAnalyticsSkillOfficeProductMetrics, powerpoint: BetaAnalyticsSkillOfficeProductMetrics, word: BetaAnalyticsSkillOfficeProductMetrics) {
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
