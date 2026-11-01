// Transformed from `anthropic.types.web_fetch_tool_result_error_code` (web_fetch_tool_result_error_code.py).

import Foundation

public enum WebFetchToolResultErrorCode: OpenEnum, CaseIterable {
    case invalidToolInput
    case urlTooLong
    case urlNotAllowed
    case urlNotInPriorContext
    case urlNotAccessible
    case unsupportedContentType
    case tooManyRequests
    case maxUsesExceeded
    case unavailable
    case contentTooLarge
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [WebFetchToolResultErrorCode] = [.invalidToolInput, .urlTooLong, .urlNotAllowed, .urlNotInPriorContext, .urlNotAccessible, .unsupportedContentType, .tooManyRequests, .maxUsesExceeded, .unavailable, .contentTooLarge]

    public init(rawValue: String) {
        switch rawValue {
        case "invalid_tool_input": self = .invalidToolInput
        case "url_too_long": self = .urlTooLong
        case "url_not_allowed": self = .urlNotAllowed
        case "url_not_in_prior_context": self = .urlNotInPriorContext
        case "url_not_accessible": self = .urlNotAccessible
        case "unsupported_content_type": self = .unsupportedContentType
        case "too_many_requests": self = .tooManyRequests
        case "max_uses_exceeded": self = .maxUsesExceeded
        case "unavailable": self = .unavailable
        case "content_too_large": self = .contentTooLarge
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .invalidToolInput: return "invalid_tool_input"
        case .urlTooLong: return "url_too_long"
        case .urlNotAllowed: return "url_not_allowed"
        case .urlNotInPriorContext: return "url_not_in_prior_context"
        case .urlNotAccessible: return "url_not_accessible"
        case .unsupportedContentType: return "unsupported_content_type"
        case .tooManyRequests: return "too_many_requests"
        case .maxUsesExceeded: return "max_uses_exceeded"
        case .unavailable: return "unavailable"
        case .contentTooLarge: return "content_too_large"
        case .unknown(let value): return value
        }
    }
}
