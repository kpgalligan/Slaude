// Transformed from `anthropic.types.shared.not_found_error` (not_found_error.py).

import Foundation

public struct SharedNotFoundError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "not_found_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
