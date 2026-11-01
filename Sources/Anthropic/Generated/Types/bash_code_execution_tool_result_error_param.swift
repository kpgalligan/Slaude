// Transformed from `anthropic.types.bash_code_execution_tool_result_error_param` (bash_code_execution_tool_result_error_param.py).

import Foundation

public struct BashCodeExecutionToolResultErrorParam: Codable, Hashable, Sendable {
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
