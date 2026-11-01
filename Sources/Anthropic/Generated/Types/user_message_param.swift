// Transformed from `anthropic.types.user_message_param` (user_message_param.py).

import Foundation

public struct UserMessageParam: Codable, Hashable, Sendable {
    public var content: MessageContentParam
    public var role: String

    public init(content: MessageContentParam, role: String = "user") {
        self.content = content
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }
}
