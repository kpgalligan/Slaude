// Transformed from `anthropic.types.beta.beta_input_tokens_trigger_param` (beta_input_tokens_trigger_param.py).

import Foundation

public struct BetaInputTokensTriggerParam: Codable, Hashable, Sendable {
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
