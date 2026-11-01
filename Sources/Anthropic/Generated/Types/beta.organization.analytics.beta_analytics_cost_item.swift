// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_cost_item` (beta_analytics_cost_item.py).

import Foundation

public struct BetaAnalyticsCostItem: Codable, Hashable, Sendable {
    /// Cost for this row.
    public var cost: BetaAnalyticsCostMetrics
    /// End of the period this row covers (exclusive), as an RFC 3339 UTC timestamp: the
    /// end of the row's time bucket when a time-bucket width is set; otherwise the
    /// requested `ending_at` (or, when omitted, the earlier of now and `starting_at`
    /// plus 31 days) rounded down to the hour, because without a time bucket the report
    /// covers whole hours.
    public var endingAt: Date
    /// The dimension values this row's cost is broken out by.
    public var group: BetaAnalyticsCostGroup
    /// Start of the period this row covers (inclusive), as an RFC 3339 UTC timestamp:
    /// the start of the row's time bucket when a time-bucket width is set, otherwise
    /// the requested `starting_at` rounded down to the hour.
    public var startingAt: Date

    public init(cost: BetaAnalyticsCostMetrics, endingAt: Date, group: BetaAnalyticsCostGroup, startingAt: Date) {
        self.cost = cost
        self.endingAt = endingAt
        self.group = group
        self.startingAt = startingAt
    }

    enum CodingKeys: String, CodingKey {
        case cost
        case endingAt = "ending_at"
        case group
        case startingAt = "starting_at"
    }
}
