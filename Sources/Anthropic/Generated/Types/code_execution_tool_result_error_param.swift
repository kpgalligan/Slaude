// Transformed from `anthropic.types.code_execution_tool_result_error_param` (code_execution_tool_result_error_param.py).

import Foundation

public struct CodeExecutionToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: CodeExecutionToolResultErrorCode
    public var type: String

    public init(errorCode: CodeExecutionToolResultErrorCode, type: String = "code_execution_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
