// Transformed from `anthropic.types.shared.overloaded_error` (overloaded_error.py).

import Foundation

public struct SharedOverloadedError: Codable, Hashable, Sendable {
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
