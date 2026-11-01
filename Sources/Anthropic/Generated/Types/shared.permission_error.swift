// Transformed from `anthropic.types.shared.permission_error` (permission_error.py).

import Foundation

public struct PermissionError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "permission_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
