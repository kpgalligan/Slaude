// Transformed from `anthropic.types.code_execution_tool_result_block` (code_execution_tool_result_block.py).

import Foundation

public struct CodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: CodeExecutionToolResultBlockContent
    public var toolUseID: String
    public var type: String

    public init(content: CodeExecutionToolResultBlockContent, toolUseID: String, type: String = "code_execution_tool_result") {
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
