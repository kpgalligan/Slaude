// Transformed from `anthropic.types.text_editor_code_execution_tool_result_error_param` (text_editor_code_execution_tool_result_error_param.py).

import Foundation

public struct TextEditorCodeExecutionToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: TextEditorCodeExecutionToolResultErrorCode
    public var type: String
    public var errorMessage: String??

    public init(errorCode: TextEditorCodeExecutionToolResultErrorCode, type: String = "text_editor_code_execution_tool_result_error", errorMessage: String?? = nil) {
        self.errorCode = errorCode
        self.type = type
        self.errorMessage = errorMessage
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
        case errorMessage = "error_message"
    }
}
