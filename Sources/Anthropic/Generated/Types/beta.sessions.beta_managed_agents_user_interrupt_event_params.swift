// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_interrupt_event_params` (beta_managed_agents_user_interrupt_event_params.py).

import Foundation

/// Parameters for sending an interrupt to pause the agent.
public struct BetaManagedAgentsUserInterruptEventParams: Codable, Hashable, Sendable {
    public var type: String
    /// If absent, interrupts every non-archived thread in a multiagent session (or the
    /// primary alone in a single-agent session). If present, interrupts only the named
    /// thread.
    public var sessionThreadId: String??

    public init(type: String = "user.interrupt", sessionThreadId: String?? = nil) {
        self.type = type
        self.sessionThreadId = sessionThreadId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case sessionThreadId = "session_thread_id"
    }
}
