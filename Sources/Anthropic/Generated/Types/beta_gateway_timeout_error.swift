// Transformed from `anthropic.types.beta_gateway_timeout_error` (beta_gateway_timeout_error.py).

import Foundation

public struct BetaGatewayTimeoutError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "timeout_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
