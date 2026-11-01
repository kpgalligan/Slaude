// Transformed from `anthropic.types.direct_caller_param` (direct_caller_param.py).

import Foundation

/// Tool invocation directly from the model.
public struct DirectCallerParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "direct") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
