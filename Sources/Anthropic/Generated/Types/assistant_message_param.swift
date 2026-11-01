// Transformed from `anthropic.types.assistant_message_param` (assistant_message_param.py).

import Foundation

public struct AssistantMessageParam: Codable, Hashable, Sendable {
    public var content: MessageContentParam
    public var role: String

    public init(content: MessageContentParam, role: String = "assistant") {
        self.content = content
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }
}
