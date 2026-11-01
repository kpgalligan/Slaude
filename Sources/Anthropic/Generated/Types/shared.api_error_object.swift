// Transformed from `anthropic.types.shared.api_error_object` (api_error_object.py).

import Foundation

public struct APIErrorObject: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "api_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
