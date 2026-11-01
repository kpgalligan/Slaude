// Transformed from `anthropic.types.tool_search_tool_result_error` (tool_search_tool_result_error.py).

import Foundation

public struct ToolSearchToolResultError: Codable, Hashable, Sendable {
    public var errorCode: ToolSearchToolResultErrorCode
    public var errorMessage: String?
    public var type: String

    public init(errorCode: ToolSearchToolResultErrorCode, errorMessage: String? = nil, type: String = "tool_search_tool_result_error") {
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
