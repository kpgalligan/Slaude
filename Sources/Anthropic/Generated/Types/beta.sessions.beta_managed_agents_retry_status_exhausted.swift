// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_retry_status_exhausted` (beta_managed_agents_retry_status_exhausted.py).

import Foundation

/// This turn is dead; queued inputs are flushed and the session returns to idle.
///
/// Client may send a new prompt.
public struct BetaManagedAgentsRetryStatusExhausted: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "exhausted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
