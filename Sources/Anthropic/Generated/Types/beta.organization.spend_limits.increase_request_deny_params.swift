// Transformed from `anthropic.types.beta.organization.spend_limits.increase_request_deny_params` (increase_request_deny_params.py).

import Foundation

public struct IncreaseRequestDenyParams: Codable, Hashable, Sendable {
    public var suppressNotification: Bool?

    public init(suppressNotification: Bool? = nil) {
        self.suppressNotification = suppressNotification
    }

    enum CodingKeys: String, CodingKey {
        case suppressNotification = "suppress_notification"
    }
}
