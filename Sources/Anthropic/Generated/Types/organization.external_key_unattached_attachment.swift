// Transformed from `anthropic.types.organization.external_key_unattached_attachment` (external_key_unattached_attachment.py).

import Foundation

public struct ExternalKeyUnattachedAttachment: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unattached") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
