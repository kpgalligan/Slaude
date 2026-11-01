// Transformed from `anthropic.types.beta.beta_managed_agents_session_creation_rejected_run_error` (beta_managed_agents_session_creation_rejected_run_error.py).

import Foundation

/// The session create request was rejected with a non-retryable validation error.
public struct BetaManagedAgentsSessionCreationRejectedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "session_creation_rejected_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
