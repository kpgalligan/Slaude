// Transformed from `anthropic.types.code_execution_tool_result_block_param` (code_execution_tool_result_block_param.py).

import Foundation

public struct CodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: CodeExecutionToolResultBlockParamContentParam
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(content: CodeExecutionToolResultBlockParamContentParam, toolUseId: String, type: String = "code_execution_tool_result", cacheControl: CacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}
