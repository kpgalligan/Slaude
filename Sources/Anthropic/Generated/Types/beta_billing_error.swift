// Transformed from `anthropic.types.beta_billing_error` (beta_billing_error.py).

import Foundation

public struct BetaBillingError: Codable, Hashable, Sendable {
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
