// Transformed from `anthropic.types.beta.beta_citations_config_param_param` (beta_citations_config_param_param.py).

import Foundation

public struct BetaCitationsConfigParamParam: Codable, Hashable, Sendable {
    public var enabled: Bool?

    public init(enabled: Bool? = nil) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
