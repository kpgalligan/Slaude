// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_error_param` (beta_code_execution_tool_result_error_param.py).

import Foundation

public struct BetaCodeExecutionToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: BetaCodeExecutionToolResultErrorCode
    public var type: String

    public init(errorCode: BetaCodeExecutionToolResultErrorCode, type: String = "code_execution_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
