// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_interrupt_event` (beta_managed_agents_user_interrupt_event.py).

import Foundation

/// An interrupt event that pauses agent execution and returns control to the user.
public struct BetaManagedAgentsUserInterruptEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    public var type: String
    /// Timestamp when the interrupt was processed.
    public var processedAt: Date?
    /// If absent, interrupts every non-archived thread in a multiagent session (or the
    /// primary alone in a single-agent session). If present, interrupts only the named
    /// thread.
    public var sessionThreadID: String?

    public init(id: String, type: String = "user.interrupt", processedAt: Date? = nil, sessionThreadID: String? = nil) {
        self.id = id
        self.type = type
        self.processedAt = processedAt
        self.sessionThreadID = sessionThreadID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case processedAt = "processed_at"
        case sessionThreadID = "session_thread_id"
    }
}
