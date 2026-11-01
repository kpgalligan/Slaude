// Transformed from `anthropic.types.text_editor_code_execution_tool_result_error` (text_editor_code_execution_tool_result_error.py).

import Foundation

public struct TextEditorCodeExecutionToolResultError: Codable, Hashable, Sendable {
    public var errorCode: TextEditorCodeExecutionToolResultErrorCode
    public var errorMessage: String?
    public var type: String

    public init(errorCode: TextEditorCodeExecutionToolResultErrorCode, errorMessage: String? = nil, type: String = "text_editor_code_execution_tool_result_error") {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case type
    }
}
