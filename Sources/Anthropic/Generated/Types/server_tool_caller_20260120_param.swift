// Transformed from `anthropic.types.server_tool_caller_20260120_param` (server_tool_caller_20260120_param.py).

import Foundation

public struct ServerToolCaller20260120Param: Codable, Hashable, Sendable {
    public var toolID: String
    public var type: String

    public init(toolID: String, type: String = "code_execution_20260120") {
        self.toolID = toolID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolID = "tool_id"
        case type
    }
}
