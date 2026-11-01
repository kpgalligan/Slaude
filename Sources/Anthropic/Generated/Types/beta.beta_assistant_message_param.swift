// Transformed from `anthropic.types.beta.beta_assistant_message_param` (beta_assistant_message_param.py).

import Foundation

public struct BetaAssistantMessageParam: Codable, Hashable, Sendable {
    public var content: BetaMessageContentParam
    public var role: String

    public init(content: BetaMessageContentParam, role: String = "assistant") {
        self.content = content
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }
}
