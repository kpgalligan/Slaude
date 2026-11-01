// Transformed from `anthropic.types.shared.gateway_timeout_error` (gateway_timeout_error.py).

import Foundation

public struct GatewayTimeoutError: Codable, Hashable, Sendable {
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
