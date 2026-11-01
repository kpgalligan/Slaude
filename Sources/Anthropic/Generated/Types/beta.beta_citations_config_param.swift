// Transformed from `anthropic.types.beta.beta_citations_config_param` (beta_citations_config_param.py).

import Foundation

public struct BetaCitationsConfigParam: Codable, Hashable, Sendable {
    public var enabled: Bool?

    public init(enabled: Bool? = nil) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
