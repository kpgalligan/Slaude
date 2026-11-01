// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_retries_exhausted` (beta_managed_agents_session_retries_exhausted.py).

import Foundation

/// The turn ended because repeated errors exhausted the retry budget or an error escalated to `retry_status: 'exhausted'`.
public struct BetaManagedAgentsSessionRetriesExhausted: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "retries_exhausted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
