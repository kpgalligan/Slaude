// Transformed from `anthropic.types.beta.beta_managed_agents_system_message_event` (beta_managed_agents_system_message_event.py).

import Foundation

/// A mid-conversation system message event.
///
/// Carries system-role content that is appended to the session as a `role: "system"` turn.
public struct BetaManagedAgentsSystemMessageEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// System content blocks. Text-only.
    public var content: [BetaManagedAgentsSystemContentBlock]
    public var type: String
    /// Timestamp when this system message was processed.
    public var processedAt: Date?

    public init(id: String, content: [BetaManagedAgentsSystemContentBlock], type: String = "system.message", processedAt: Date? = nil) {
        self.id = id
        self.content = content
        self.type = type
        self.processedAt = processedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case type
        case processedAt = "processed_at"
    }
}
