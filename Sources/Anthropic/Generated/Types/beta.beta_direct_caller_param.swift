// Transformed from `anthropic.types.beta.beta_direct_caller_param` (beta_direct_caller_param.py).

import Foundation

/// Tool invocation directly from the model.
public struct BetaDirectCallerParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "direct") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
