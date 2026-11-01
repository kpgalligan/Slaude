// Transformed from `anthropic.types.beta.beta_dream_error` (beta_dream_error.py).

import Foundation

/// Failure detail for a Dream whose `status` is `failed`.
public struct BetaDreamError: Codable, Hashable, Sendable {
    /// A human-readable explanation of why the dream failed.
    public var message: String
    /// A code for why the dream failed, such as `timeout` or `internal_error`.
    ///
    /// The
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#errors)
    /// lists common error codes and when they occur.
    public var type: String

    public init(message: String, type: String) {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
