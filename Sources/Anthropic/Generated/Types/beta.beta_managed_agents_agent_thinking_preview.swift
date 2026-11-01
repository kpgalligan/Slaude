// Transformed from `anthropic.types.beta.beta_managed_agents_agent_thinking_preview` (beta_managed_agents_agent_thinking_preview.py).

import Foundation

public struct BetaManagedAgentsAgentThinkingPreview: Codable, Hashable, Sendable {
    /// The id the buffered agent.thinking will carry if it is emitted.
    ///
    /// Start-only — no event_delta events follow.
    public var id: String
    public var type: String

    public init(id: String, type: String = "agent.thinking") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
