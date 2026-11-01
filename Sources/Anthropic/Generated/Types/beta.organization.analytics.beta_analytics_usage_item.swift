// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_usage_item` (beta_analytics_usage_item.py).

import Foundation

public struct BetaAnalyticsUsageItem: Codable, Hashable, Sendable {
    /// End of the period this row covers (exclusive), as an RFC 3339 UTC timestamp: the
    /// end of the row's time bucket when a time-bucket width is set; otherwise the
    /// requested `ending_at` (or, when omitted, the earlier of now and `starting_at`
    /// plus 31 days) rounded down to the hour, because without a time bucket the report
    /// covers whole hours.
    public var endingAt: Date
    /// The dimension values this row's usage is broken out by.
    public var group: BetaAnalyticsUsageGroup
    /// Start of the period this row covers (inclusive), as an RFC 3339 UTC timestamp:
    /// the start of the row's time bucket when a time-bucket width is set, otherwise
    /// the requested `starting_at` rounded down to the hour.
    public var startingAt: Date
    /// Token usage for this row.
    public var usage: BetaAnalyticsUsageMetrics

    public init(endingAt: Date, group: BetaAnalyticsUsageGroup, startingAt: Date, usage: BetaAnalyticsUsageMetrics) {
        self.endingAt = endingAt
        self.group = group
        self.startingAt = startingAt
        self.usage = usage
    }

    enum CodingKeys: String, CodingKey {
        case endingAt = "ending_at"
        case group
        case startingAt = "starting_at"
        case usage
    }
}
