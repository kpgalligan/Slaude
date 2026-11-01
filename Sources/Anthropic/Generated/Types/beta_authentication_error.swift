// Transformed from `anthropic.types.beta_authentication_error` (beta_authentication_error.py).

import Foundation

public struct BetaAuthenticationError: Codable, Hashable, Sendable {
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
