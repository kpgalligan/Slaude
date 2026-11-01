// Transformed from `anthropic.types.beta.organization.beta_analytics_cost_report_time_bucket` (beta_analytics_cost_report_time_bucket.py).

import Foundation

public struct BetaAnalyticsCostReportTimeBucket: Codable, Hashable, Sendable {
    /// End of the time bucket (exclusive) in RFC 3339 format.
    public var endingAt: Date
    /// Rows for this time bucket.
    ///
    /// Empty when the bucket has no data; otherwise a single combined row when
    /// `group_by[]` is omitted, or one row per group (subject to the per-bucket group
    /// cap described on the `group_by[]` parameter).
    public var results: [BetaAnalyticsCostBucketedResult]
    /// Start of the time bucket (inclusive) in RFC 3339 format.
    public var startingAt: Date

    public init(endingAt: Date, results: [BetaAnalyticsCostBucketedResult], startingAt: Date) {
        self.endingAt = endingAt
        self.results = results
        self.startingAt = startingAt
    }

    enum CodingKeys: String, CodingKey {
        case endingAt = "ending_at"
        case results
        case startingAt = "starting_at"
    }
}
