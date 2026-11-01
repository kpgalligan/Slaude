// Transformed from `anthropic.types.bash_code_execution_tool_result_error_code` (bash_code_execution_tool_result_error_code.py).

import Foundation

public enum BashCodeExecutionToolResultErrorCode: OpenEnum, CaseIterable {
    case invalidToolInput
    case unavailable
    case tooManyRequests
    case executionTimeExceeded
    case outputFileTooLarge
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BashCodeExecutionToolResultErrorCode] = [.invalidToolInput, .unavailable, .tooManyRequests, .executionTimeExceeded, .outputFileTooLarge]

    public init(rawValue: String) {
        switch rawValue {
        case "invalid_tool_input": self = .invalidToolInput
        case "unavailable": self = .unavailable
        case "too_many_requests": self = .tooManyRequests
        case "execution_time_exceeded": self = .executionTimeExceeded
        case "output_file_too_large": self = .outputFileTooLarge
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .invalidToolInput: return "invalid_tool_input"
        case .unavailable: return "unavailable"
        case .tooManyRequests: return "too_many_requests"
        case .executionTimeExceeded: return "execution_time_exceeded"
        case .outputFileTooLarge: return "output_file_too_large"
        case .unknown(let value): return value
        }
    }
}
