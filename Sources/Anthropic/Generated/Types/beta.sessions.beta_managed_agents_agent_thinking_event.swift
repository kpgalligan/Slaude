// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_thinking_event` (beta_managed_agents_agent_thinking_event.py).

import Foundation

/// Indicates the agent is making forward progress via extended thinking.
///
/// A progress signal, not a content carrier.
public struct BetaManagedAgentsAgentThinkingEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when this thinking was produced.
    public var processedAt: Date
    public var type: String

    public init(id: String, processedAt: Date, type: String = "agent.thinking") {
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
