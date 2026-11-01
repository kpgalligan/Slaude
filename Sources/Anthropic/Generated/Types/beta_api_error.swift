// Transformed from `anthropic.types.beta_api_error` (beta_api_error.py).

import Foundation

public struct BetaAPIError: Codable, Hashable, Sendable {
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
