// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_block` (beta_code_execution_tool_result_block.py).

import Foundation

public struct BetaCodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaCodeExecutionToolResultBlockContent
    public var toolUseId: String
    public var type: String

    public init(content: BetaCodeExecutionToolResultBlockContent, toolUseId: String, type: String = "code_execution_tool_result") {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
    }
}
