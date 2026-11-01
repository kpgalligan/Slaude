// Transformed from `anthropic.types.beta.beta_citation_config` (beta_citation_config.py).

import Foundation

public struct BetaCitationConfig: Codable, Hashable, Sendable {
    public var enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
