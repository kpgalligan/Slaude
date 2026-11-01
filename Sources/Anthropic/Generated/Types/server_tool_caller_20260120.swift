// Transformed from `anthropic.types.server_tool_caller_20260120` (server_tool_caller_20260120.py).

import Foundation

public struct ServerToolCaller20260120: Codable, Hashable, Sendable {
    public var toolId: String
    public var type: String

    public init(toolId: String, type: String = "code_execution_20260120") {
        self.toolId = toolId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolId = "tool_id"
        case type
    }
}
