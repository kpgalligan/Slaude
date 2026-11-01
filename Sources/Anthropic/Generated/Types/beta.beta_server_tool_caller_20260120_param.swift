// Transformed from `anthropic.types.beta.beta_server_tool_caller_20260120_param` (beta_server_tool_caller_20260120_param.py).

import Foundation

public struct BetaServerToolCaller20260120Param: Codable, Hashable, Sendable {
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
