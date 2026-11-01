// Transformed from `anthropic.types.beta.beta_managed_agents_schedule` (beta_managed_agents_schedule.py).

import Foundation

/// A recurring schedule with computed runtime timestamps.
///
/// Discriminated union — only cron is supported currently.
public struct BetaManagedAgentsSchedule: Codable, Hashable, Sendable {
    /// 5-field POSIX cron expression: minute hour day-of-month month day-of-week (e.g.,
    /// "0 9 \** \** 1-5" for weekdays at 9am). Day-of-week is 0-7 where 0 and 7 both mean
    /// Sunday. Extended cron syntax - seconds or year fields, and the special
    /// characters L, W, #, and ? - is not supported, nor are predefined shortcuts
    /// (@daily).
    public var expression: String
    /// IANA timezone identifier (e.g., "America/Los_Angeles", "UTC").
    public var timezone: String
    public var type: String
    /// Time the most recent scheduled run actually started.
    ///
    /// Null until one completes; preserved after the deployment is archived. Manual
    /// runs do not update this.
    public var lastRunAt: Date?
    /// Up to 5 timestamps of upcoming cron occurrences.
    ///
    /// Non-empty for active and paused deployments (reflects what the schedule would do
    /// if unpaused); empty once the deployment is archived (`archived_at` set). Each
    /// fire is offset by a small per-schedule jitter, so a run will actually start at
    /// or shortly after its listed time.
    public var upcomingRunsAt: [Date]?

    public init(expression: String, timezone: String, type: String = "cron", lastRunAt: Date? = nil, upcomingRunsAt: [Date]? = nil) {
        self.expression = expression
        self.timezone = timezone
        self.type = type
        self.lastRunAt = lastRunAt
        self.upcomingRunsAt = upcomingRunsAt
    }

    enum CodingKeys: String, CodingKey {
        case expression
        case timezone
        case type
        case lastRunAt = "last_run_at"
        case upcomingRunsAt = "upcoming_runs_at"
    }
}
