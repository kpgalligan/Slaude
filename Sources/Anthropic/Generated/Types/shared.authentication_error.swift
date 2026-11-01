// Transformed from `anthropic.types.shared.authentication_error` (authentication_error.py).

import Foundation

public struct SharedAuthenticationError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "authentication_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
