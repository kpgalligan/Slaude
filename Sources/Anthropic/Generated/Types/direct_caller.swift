// Transformed from `anthropic.types.direct_caller` (direct_caller.py).

import Foundation

/// Tool invocation directly from the model.
public struct DirectCaller: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "direct") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
