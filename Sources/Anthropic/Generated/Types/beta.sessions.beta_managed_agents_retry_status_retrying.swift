// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_retry_status_retrying` (beta_managed_agents_retry_status_retrying.py).

import Foundation

/// The server is retrying automatically.
///
/// Client should wait; the same error type may fire again as retrying, then once as exhausted when the retry budget runs out.
public struct BetaManagedAgentsRetryStatusRetrying: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "retrying") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
