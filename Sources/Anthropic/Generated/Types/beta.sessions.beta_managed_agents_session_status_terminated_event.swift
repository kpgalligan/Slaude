// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_status_terminated_event` (beta_managed_agents_session_status_terminated_event.py).

import Foundation

/// Indicates the session has terminated, either due to an error or completion.
public struct BetaManagedAgentsSessionStatusTerminatedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp of status change.
    public var processedAt: Date
    public var type: String

    public init(id: String, processedAt: Date, type: String = "session.status_terminated") {
        self.id = id
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
    }
}
