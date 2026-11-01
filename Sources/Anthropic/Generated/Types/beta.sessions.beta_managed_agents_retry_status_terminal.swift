// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_retry_status_terminal` (beta_managed_agents_retry_status_terminal.py).

import Foundation

/// The session encountered a terminal error and will transition to `terminated` state.
public struct BetaManagedAgentsRetryStatusTerminal: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "terminal") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
