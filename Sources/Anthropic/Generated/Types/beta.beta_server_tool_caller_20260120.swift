// Transformed from `anthropic.types.beta.beta_server_tool_caller_20260120` (beta_server_tool_caller_20260120.py).

import Foundation

public struct BetaServerToolCaller20260120: Codable, Hashable, Sendable {
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
