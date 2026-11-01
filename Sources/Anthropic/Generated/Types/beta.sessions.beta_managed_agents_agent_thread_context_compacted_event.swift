// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_thread_context_compacted_event` (beta_managed_agents_agent_thread_context_compacted_event.py).

import Foundation

/// Indicates that context compaction (summarization) occurred during the session.
public struct BetaManagedAgentsAgentThreadContextCompactedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when compaction was processed.
    public var processedAt: Date
    public var type: String

    public init(id: String, processedAt: Date, type: String = "agent.thread_context_compacted") {
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
