// Transformed from `anthropic.types.citations_config_param` (citations_config_param.py).

import Foundation

public struct CitationsConfigParam: Codable, Hashable, Sendable {
    public var enabled: Bool?

    public init(enabled: Bool? = nil) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
