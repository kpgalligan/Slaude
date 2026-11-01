// Transformed from `anthropic.types.beta.beta_web_fetch_tool_result_error_block` (beta_web_fetch_tool_result_error_block.py).

import Foundation

public struct BetaWebFetchToolResultErrorBlock: Codable, Hashable, Sendable {
    public var errorCode: BetaWebFetchToolResultErrorCode
    public var type: String

    public init(errorCode: BetaWebFetchToolResultErrorCode, type: String = "web_fetch_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }
}
