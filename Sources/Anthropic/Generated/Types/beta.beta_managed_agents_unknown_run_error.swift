// Transformed from `anthropic.types.beta.beta_managed_agents_unknown_run_error` (beta_managed_agents_unknown_run_error.py).

import Foundation

/// An unknown or unexpected error caused the run to fail.
///
/// A fallback variant; clients that do not recognize a new error type can match on message alone.
public struct BetaManagedAgentsUnknownRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "unknown_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
