// Transformed from `anthropic.types.beta_permission_error` (beta_permission_error.py).

import Foundation

public struct BetaPermissionError: Codable, Hashable, Sendable {
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
