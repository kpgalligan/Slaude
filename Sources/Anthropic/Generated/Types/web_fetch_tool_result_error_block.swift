// Transformed from `anthropic.types.web_fetch_tool_result_error_block` (web_fetch_tool_result_error_block.py).

import Foundation

public struct WebFetchToolResultErrorBlock: Codable, Hashable, Sendable {
    public var errorCode: WebFetchToolResultErrorCode
    public var type: String

    public init(errorCode: WebFetchToolResultErrorCode, type: String = "web_fetch_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
