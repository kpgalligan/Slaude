// Transformed from `anthropic.types.bash_code_execution_tool_result_error` (bash_code_execution_tool_result_error.py).

import Foundation

public struct BashCodeExecutionToolResultError: Codable, Hashable, Sendable {
    public var errorCode: BashCodeExecutionToolResultErrorCode
    public var type: String

    public init(errorCode: BashCodeExecutionToolResultErrorCode, type: String = "bash_code_execution_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
