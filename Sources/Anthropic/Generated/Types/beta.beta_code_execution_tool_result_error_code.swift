// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_error_code` (beta_code_execution_tool_result_error_code.py).

import Foundation

public enum BetaCodeExecutionToolResultErrorCode: OpenEnum, CaseIterable {
    case invalidToolInput
    case unavailable
    case tooManyRequests
    case executionTimeExceeded
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaCodeExecutionToolResultErrorCode] = [.invalidToolInput, .unavailable, .tooManyRequests, .executionTimeExceeded]

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
