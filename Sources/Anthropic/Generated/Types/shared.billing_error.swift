// Transformed from `anthropic.types.shared.billing_error` (billing_error.py).

import Foundation

public struct BillingError: Codable, Hashable, Sendable {
    public var message: String
    public var type: String

    public init(message: String, type: String = "billing_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
