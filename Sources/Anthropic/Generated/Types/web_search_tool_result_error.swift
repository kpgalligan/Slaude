// Transformed from `anthropic.types.web_search_tool_result_error` (web_search_tool_result_error.py).

import Foundation

public struct WebSearchToolResultError: Codable, Hashable, Sendable {
    public var errorCode: WebSearchToolResultErrorCode
    public var type: String

    public init(errorCode: WebSearchToolResultErrorCode, type: String = "web_search_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
