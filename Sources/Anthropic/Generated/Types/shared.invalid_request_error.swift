// Transformed from `anthropic.types.shared.invalid_request_error` (invalid_request_error.py).

import Foundation

public struct InvalidRequestError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "invalid_request_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
