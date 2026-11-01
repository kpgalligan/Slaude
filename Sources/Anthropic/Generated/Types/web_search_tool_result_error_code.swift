// Transformed from `anthropic.types.web_search_tool_result_error_code` (web_search_tool_result_error_code.py).

import Foundation

public enum WebSearchToolResultErrorCode: OpenEnum, CaseIterable {
    case invalidToolInput
    case unavailable
    case maxUsesExceeded
    case tooManyRequests
    case queryTooLong
    case requestTooLarge
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [WebSearchToolResultErrorCode] = [.invalidToolInput, .unavailable, .maxUsesExceeded, .tooManyRequests, .queryTooLong, .requestTooLarge]

    public init(rawValue: String) {
        switch rawValue {
        case "invalid_tool_input": self = .invalidToolInput
        case "unavailable": self = .unavailable
        case "max_uses_exceeded": self = .maxUsesExceeded
        case "too_many_requests": self = .tooManyRequests
        case "query_too_long": self = .queryTooLong
        case "request_too_large": self = .requestTooLarge
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .invalidToolInput: return "invalid_tool_input"
        case .unavailable: return "unavailable"
        case .maxUsesExceeded: return "max_uses_exceeded"
        case .tooManyRequests: return "too_many_requests"
        case .queryTooLong: return "query_too_long"
        case .requestTooLarge: return "request_too_large"
        case .unknown(let value): return value
        }
    }
}
