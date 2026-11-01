// Transformed from `anthropic.types.beta.beta_input_tokens_clear_at_least_param` (beta_input_tokens_clear_at_least_param.py).

import Foundation

public struct BetaInputTokensClearAtLeastParam: Codable, Hashable, Sendable {
    public var type: String
    public var value: Int

    public init(type: String = "input_tokens", value: Int) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}
