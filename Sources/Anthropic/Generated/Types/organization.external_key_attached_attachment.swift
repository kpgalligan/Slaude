// Transformed from `anthropic.types.organization.external_key_attached_attachment` (external_key_attached_attachment.py).

import Foundation

public struct ExternalKeyAttachedAttachment: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "attached") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
