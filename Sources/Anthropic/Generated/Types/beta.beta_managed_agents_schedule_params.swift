// Transformed from `anthropic.types.beta.beta_managed_agents_schedule_params` (beta_managed_agents_schedule_params.py).

import Foundation

/// A recurring schedule. Discriminated union — only cron is supported currently.
public struct BetaManagedAgentsScheduleParams: Codable, Hashable, Sendable {
    /// 5-field POSIX cron expression: minute hour day-of-month month day-of-week (e.g.,
    /// "0 9 \** \** 1-5" for weekdays at 9am). Day-of-week is 0-7 where 0 and 7 both mean
    /// Sunday. Extended cron syntax - seconds or year fields, and the special
    /// characters L, W, #, and ? - is not supported, nor are predefined shortcuts
    /// (@daily).
    public var expression: String
    /// Required.
    ///
    /// IANA timezone identifier (e.g., "America/Los_Angeles", "UTC"). Validated against
    /// the IANA timezone database.
    public var timezone: String
    public var type: String

    public init(expression: String, timezone: String, type: String = "cron") {
        self.expression = expression
        self.timezone = timezone
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case expression
        case timezone
        case type
    }
}
