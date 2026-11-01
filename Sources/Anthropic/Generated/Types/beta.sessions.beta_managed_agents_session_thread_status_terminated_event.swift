// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_status_terminated_event` (beta_managed_agents_session_thread_status_terminated_event.py).

import Foundation

/// A session thread has terminated and will accept no further input.
///
/// Emitted on the thread's own stream and cross-posted to the primary stream for child threads.
public struct BetaManagedAgentsSessionThreadStatusTerminatedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Name of the agent the thread runs.
    public var agentName: String
    /// Timestamp of the status transition.
    public var processedAt: Date
    /// Public sthr\__ ID of the thread that terminated.
    public var sessionThreadID: String
    public var type: String

    public init(id: String, agentName: String, processedAt: Date, sessionThreadID: String, type: String = "session.thread_status_terminated") {
        self.id = id
        self.agentName = agentName
        self.processedAt = processedAt
        self.sessionThreadID = sessionThreadID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agentName = "agent_name"
        case processedAt = "processed_at"
        case sessionThreadID = "session_thread_id"
        case type
    }
}
