// Transformed from `anthropic.types.beta.beta_managed_agents_agent_message_preview` (beta_managed_agents_agent_message_preview.py).

import Foundation

public struct BetaManagedAgentsAgentMessagePreview: Codable, Hashable, Sendable {
    /// The id the buffered agent.message will carry if it is emitted.
    ///
    /// Matches the event_id on this preview's event_delta events.
    public var id: String
    public var type: String

    public init(id: String, type: String = "agent.message") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
