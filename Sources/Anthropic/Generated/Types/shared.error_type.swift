// Transformed from `anthropic.types.shared.error_type` (error_type.py).

import Foundation

public enum ErrorType: OpenEnum, CaseIterable {
    case invalidRequestError
    case authenticationError
    case permissionError
    case notFoundError
    case rateLimitError
    case timeoutError
    case overloadedError
    case apiError
    case billingError
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [ErrorType] = [.invalidRequestError, .authenticationError, .permissionError, .notFoundError, .rateLimitError, .timeoutError, .overloadedError, .apiError, .billingError]

    public init(rawValue: String) {
        switch rawValue {
        case "invalid_request_error": self = .invalidRequestError
        case "authentication_error": self = .authenticationError
        case "permission_error": self = .permissionError
        case "not_found_error": self = .notFoundError
        case "rate_limit_error": self = .rateLimitError
        case "timeout_error": self = .timeoutError
        case "overloaded_error": self = .overloadedError
        case "api_error": self = .apiError
        case "billing_error": self = .billingError
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .invalidRequestError: return "invalid_request_error"
        case .authenticationError: return "authentication_error"
        case .permissionError: return "permission_error"
        case .notFoundError: return "not_found_error"
        case .rateLimitError: return "rate_limit_error"
        case .timeoutError: return "timeout_error"
        case .overloadedError: return "overloaded_error"
        case .apiError: return "api_error"
        case .billingError: return "billing_error"
        case .unknown(let value): return value
        }
    }
}
