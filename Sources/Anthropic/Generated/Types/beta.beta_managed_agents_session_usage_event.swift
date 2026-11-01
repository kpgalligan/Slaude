// Transformed from `anthropic.types.beta.beta_managed_agents_session_usage_event` (beta_managed_agents_session_usage_event.py).

import Foundation

/// Periodic snapshot of the session's cumulative usage and tracked list cost.
public struct BetaManagedAgentsSessionUsageEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when the snapshot was taken.
    public var processedAt: Date
    public var type: String
    /// The session's cumulative usage at the snapshot time.
    public var usage: BetaManagedAgentsSessionUsageSnapshot
    /// The session's configured budget at the snapshot time, or null when the session
    /// has no budget.
    public var budget: BetaManagedAgentsBudgetLimit?

    public init(id: String, processedAt: Date, type: String = "session.usage", usage: BetaManagedAgentsSessionUsageSnapshot, budget: BetaManagedAgentsBudgetLimit? = nil) {
        self.id = id
        self.processedAt = processedAt
        self.type = type
        self.usage = usage
        self.budget = budget
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
        case usage
        case budget
    }
}
