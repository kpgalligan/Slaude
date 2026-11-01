// Transformed from `anthropic.types.beta.beta_user_message_param` (beta_user_message_param.py).

import Foundation

public struct BetaUserMessageParam: Codable, Hashable, Sendable {
    public var content: BetaMessageContentParam
    public var role: String

    public init(content: BetaMessageContentParam, role: String = "user") {
        self.content = content
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }
}
