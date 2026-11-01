// Transformed from `anthropic.types.tool_search_tool_result_error_param` (tool_search_tool_result_error_param.py).

import Foundation

public struct ToolSearchToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: ToolSearchToolResultErrorCode
    public var type: String
    public var errorMessage: String??

    public init(errorCode: ToolSearchToolResultErrorCode, type: String = "tool_search_tool_result_error", errorMessage: String?? = nil) {
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
