// Transformed from `anthropic.types.beta.beta_managed_agents_file_not_found_run_error` (beta_managed_agents_file_not_found_run_error.py).

import Foundation

/// A file resource referenced by the deployment no longer exists.
public struct BetaManagedAgentsFileNotFoundRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "file_not_found_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
