// Transformed from `anthropic.types.beta.organization.spend_limits.beta_spend_limit_increase_request_status` (beta_spend_limit_increase_request_status.py).

import Foundation

public enum BetaSpendLimitIncreaseRequestStatus: OpenEnum, CaseIterable {
    case approved
    case denied
    case pending
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaSpendLimitIncreaseRequestStatus] = [.approved, .denied, .pending]

    public init(rawValue: String) {
        switch rawValue {
        case "approved": self = .approved
        case "denied": self = .denied
        case "pending": self = .pending
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .approved: return "approved"
        case .denied: return "denied"
        case .pending: return "pending"
        case .unknown(let value): return value
        }
    }
}
