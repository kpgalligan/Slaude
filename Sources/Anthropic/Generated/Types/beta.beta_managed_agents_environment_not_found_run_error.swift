// Transformed from `anthropic.types.beta.beta_managed_agents_environment_not_found_run_error` (beta_managed_agents_environment_not_found_run_error.py).

import Foundation

/// The deployment's environment no longer exists.
public struct BetaManagedAgentsEnvironmentNotFoundRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "environment_not_found_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
