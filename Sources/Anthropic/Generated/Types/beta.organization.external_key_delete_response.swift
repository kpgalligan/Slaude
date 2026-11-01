// Transformed from `anthropic.types.beta.organization.external_key_delete_response` (external_key_delete_response.py).

import Foundation

public struct BetaOrganizationExternalKeyDeleteResponse: Codable, Hashable, Sendable {
    /// ID of the deleted External Key.
    public var id: String
    public var type: String

    public init(id: String, type: String = "external_key_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
