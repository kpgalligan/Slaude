// Transformed from `anthropic.types.beta.beta_tool_search_tool_result_error_param` (beta_tool_search_tool_result_error_param.py).

import Foundation

public struct BetaToolSearchToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: ErrorCode
    public var type: String
    public var errorMessage: String??

    public init(errorCode: ErrorCode, type: String = "tool_search_tool_result_error", errorMessage: String?? = nil) {
        self.errorCode = errorCode
        self.type = type
        self.errorMessage = errorMessage
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
        case errorMessage = "error_message"
    }

    public enum ErrorCode: OpenEnum, CaseIterable {
        case invalidToolInput
        case unavailable
        case tooManyRequests
        case executionTimeExceeded
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ErrorCode] = [.invalidToolInput, .unavailable, .tooManyRequests, .executionTimeExceeded]

        public init(rawValue: String) {
            switch rawValue {
            case "invalid_tool_input": self = .invalidToolInput
            case "unavailable": self = .unavailable
            case "too_many_requests": self = .tooManyRequests
            case "execution_time_exceeded": self = .executionTimeExceeded
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .invalidToolInput: return "invalid_tool_input"
            case .unavailable: return "unavailable"
            case .tooManyRequests: return "too_many_requests"
            case .executionTimeExceeded: return "execution_time_exceeded"
            case .unknown(let value): return value
            }
        }
    }
}
