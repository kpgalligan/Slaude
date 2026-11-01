// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_block_param` (beta_code_execution_tool_result_block_param.py).

import Foundation

public struct BetaCodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaCodeExecutionToolResultBlockParamContentParam
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(content: BetaCodeExecutionToolResultBlockParamContentParam, toolUseId: String, type: String = "code_execution_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
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
