// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_deleted_event` (beta_managed_agents_session_deleted_event.py).

import Foundation

/// Emitted when a session has been deleted.
///
/// Terminates any active event stream — no further events will be emitted for this session.
public struct BetaManagedAgentsSessionDeletedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when the session was deleted.
    public var processedAt: Date
    public var type: String

    public init(id: String, processedAt: Date, type: String = "session.deleted") {
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
