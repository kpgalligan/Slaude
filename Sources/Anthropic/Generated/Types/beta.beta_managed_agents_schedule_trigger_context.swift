// Transformed from `anthropic.types.beta.beta_managed_agents_schedule_trigger_context` (beta_managed_agents_schedule_trigger_context.py).

import Foundation

/// The run was fired by the deployment's cron schedule.
public struct BetaManagedAgentsScheduleTriggerContext: Codable, Hashable, Sendable {
    /// The UTC instant at which the cron expression matched in the configured timezone,
    /// before jitter is applied. At most one run is recorded per (`deployment_id`,
    /// `scheduled_at`) pair.
    public var scheduledAt: Date
    public var type: String

    public init(scheduledAt: Date, type: String = "schedule") {
        self.scheduledAt = scheduledAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case scheduledAt = "scheduled_at"
        case type
    }
}
