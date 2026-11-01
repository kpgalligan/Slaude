// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_block` (beta_code_execution_tool_result_block.py).

import Foundation

public struct BetaCodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaCodeExecutionToolResultBlockContent
    public var toolUseID: String
    public var type: String

    public init(content: BetaCodeExecutionToolResultBlockContent, toolUseID: String, type: String = "code_execution_tool_result") {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
    }
}
