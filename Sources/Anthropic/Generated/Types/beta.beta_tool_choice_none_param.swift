// Transformed from `anthropic.types.beta.beta_tool_choice_none_param` (beta_tool_choice_none_param.py).

import Foundation

/// The model will not be allowed to use tools.
public struct BetaToolChoiceNoneParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
