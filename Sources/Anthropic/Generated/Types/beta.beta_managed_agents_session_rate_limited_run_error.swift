// Transformed from `anthropic.types.beta.beta_managed_agents_session_rate_limited_run_error` (beta_managed_agents_session_rate_limited_run_error.py).

import Foundation

/// Session creation was rejected due to rate limiting.
///
/// The schedule keeps firing; subsequent runs may succeed.
public struct BetaManagedAgentsSessionRateLimitedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "session_rate_limited_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
