// Transformed from `anthropic.types.beta.organization.beta_external_key_unattached_attachment` (beta_external_key_unattached_attachment.py).

import Foundation

public struct BetaExternalKeyUnattachedAttachment: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unattached") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
