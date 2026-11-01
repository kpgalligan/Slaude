// Transformed from `anthropic.types.beta.organization.spend_limit_delete_response` (spend_limit_delete_response.py).

import Foundation

public struct SpendLimitDeleteResponse: Codable, Hashable, Sendable {
    public var id: String
    public var type: String

    public init(id: String, type: String = "spend_limit_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
