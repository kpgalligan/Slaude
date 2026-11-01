// Transformed from `anthropic.types.beta.organization.beta_external_key_attached_attachment` (beta_external_key_attached_attachment.py).

import Foundation

public struct BetaExternalKeyAttachedAttachment: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "attached") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
