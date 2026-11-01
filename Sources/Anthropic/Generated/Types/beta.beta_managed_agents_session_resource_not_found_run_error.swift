// Transformed from `anthropic.types.beta.beta_managed_agents_session_resource_not_found_run_error` (beta_managed_agents_session_resource_not_found_run_error.py).

import Foundation

/// A referenced resource no longer exists and its kind was not reported.
public struct BetaManagedAgentsSessionResourceNotFoundRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "session_resource_not_found_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
