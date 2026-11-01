// Transformed from `anthropic.types.citations_config` (citations_config.py).

import Foundation

public struct CitationsConfig: Codable, Hashable, Sendable {
    public var enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
