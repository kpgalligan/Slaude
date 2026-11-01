// Transformed from `anthropic.types.beta_overloaded_error` (beta_overloaded_error.py).

import Foundation

public struct BetaOverloadedError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "overloaded_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
