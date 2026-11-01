// Transformed from `anthropic.types.beta.beta_web_search_tool_result_error` (beta_web_search_tool_result_error.py).

import Foundation

public struct BetaWebSearchToolResultError: Codable, Hashable, Sendable {
    public var errorCode: BetaWebSearchToolResultErrorCode
    public var type: String

    public init(errorCode: BetaWebSearchToolResultErrorCode, type: String = "web_search_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
