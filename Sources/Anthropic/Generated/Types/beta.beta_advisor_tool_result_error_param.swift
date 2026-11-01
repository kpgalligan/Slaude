// Transformed from `anthropic.types.beta.beta_advisor_tool_result_error_param` (beta_advisor_tool_result_error_param.py).

import Foundation

public struct BetaAdvisorToolResultErrorParam: Codable, Hashable, Sendable {
    public var errorCode: ErrorCode
    public var type: String

    public init(errorCode: ErrorCode, type: String = "advisor_tool_result_error") {
        self.errorCode = errorCode
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case type
    }

    public enum ErrorCode: OpenEnum, CaseIterable {
        case maxUsesExceeded
        case promptTooLong
        case tooManyRequests
        case overloaded
        case unavailable
        case executionTimeExceeded
        case modelNotFound
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ErrorCode] = [.maxUsesExceeded, .promptTooLong, .tooManyRequests, .overloaded, .unavailable, .executionTimeExceeded, .modelNotFound]

        public init(rawValue: String) {
            switch rawValue {
            case "max_uses_exceeded": self = .maxUsesExceeded
            case "prompt_too_long": self = .promptTooLong
            case "too_many_requests": self = .tooManyRequests
            case "overloaded": self = .overloaded
            case "unavailable": self = .unavailable
            case "execution_time_exceeded": self = .executionTimeExceeded
            case "model_not_found": self = .modelNotFound
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .maxUsesExceeded: return "max_uses_exceeded"
            case .promptTooLong: return "prompt_too_long"
            case .tooManyRequests: return "too_many_requests"
            case .overloaded: return "overloaded"
            case .unavailable: return "unavailable"
            case .executionTimeExceeded: return "execution_time_exceeded"
            case .modelNotFound: return "model_not_found"
            case .unknown(let value): return value
            }
        }
    }
}
