// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_end_turn` (beta_managed_agents_session_end_turn.py).

import Foundation

/// The agent completed its turn naturally and is ready for the next user message.
public struct BetaManagedAgentsSessionEndTurn: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "end_turn") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
