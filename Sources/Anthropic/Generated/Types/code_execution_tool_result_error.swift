// Transformed from `anthropic.types.code_execution_tool_result_error` (code_execution_tool_result_error.py).

import Foundation

public struct CodeExecutionToolResultError: Codable, Hashable, Sendable {
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
