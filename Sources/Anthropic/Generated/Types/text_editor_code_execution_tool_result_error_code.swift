// Transformed from `anthropic.types.text_editor_code_execution_tool_result_error_code` (text_editor_code_execution_tool_result_error_code.py).

import Foundation

public enum TextEditorCodeExecutionToolResultErrorCode: OpenEnum, CaseIterable {
    case invalidToolInput
    case unavailable
    case tooManyRequests
    case executionTimeExceeded
    case fileNotFound
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [TextEditorCodeExecutionToolResultErrorCode] = [.invalidToolInput, .unavailable, .tooManyRequests, .executionTimeExceeded, .fileNotFound]

    public init(rawValue: String) {
        switch rawValue {
        case "invalid_tool_input": self = .invalidToolInput
        case "unavailable": self = .unavailable
        case "too_many_requests": self = .tooManyRequests
        case "execution_time_exceeded": self = .executionTimeExceeded
        case "file_not_found": self = .fileNotFound
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .invalidToolInput: return "invalid_tool_input"
        case .unavailable: return "unavailable"
        case .tooManyRequests: return "too_many_requests"
        case .executionTimeExceeded: return "execution_time_exceeded"
        case .fileNotFound: return "file_not_found"
        case .unknown(let value): return value
        }
    }
}
