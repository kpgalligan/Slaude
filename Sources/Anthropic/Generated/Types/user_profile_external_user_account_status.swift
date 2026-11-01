// Transformed from `anthropic.types.user_profile_external_user_account_status` (user_profile_external_user_account_status.py).

import Foundation

public enum UserProfileExternalUserAccountStatus: OpenEnum, CaseIterable {
    case active
    case suspended
    case blocked
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileExternalUserAccountStatus] = [.active, .suspended, .blocked]

    public init(rawValue: String) {
        switch rawValue {
        case "active": self = .active
        case "suspended": self = .suspended
        case "blocked": self = .blocked
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .active: return "active"
        case .suspended: return "suspended"
        case .blocked: return "blocked"
        case .unknown(let value): return value
        }
    }
}
