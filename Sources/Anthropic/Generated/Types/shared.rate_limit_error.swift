// Transformed from `anthropic.types.shared.rate_limit_error` (rate_limit_error.py).

import Foundation

public struct SharedRateLimitError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "rate_limit_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
