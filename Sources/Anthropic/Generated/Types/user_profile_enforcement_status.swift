// Transformed from `anthropic.types.user_profile_enforcement_status` (user_profile_enforcement_status.py).

import Foundation

public enum UserProfileEnforcementStatus: OpenEnum, CaseIterable {
    case unrestricted
    case pending
    case restricted
    case banned
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileEnforcementStatus] = [.unrestricted, .pending, .restricted, .banned]

    public init(rawValue: String) {
        switch rawValue {
        case "unrestricted": self = .unrestricted
        case "pending": self = .pending
        case "restricted": self = .restricted
        case "banned": self = .banned
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .unrestricted: return "unrestricted"
        case .pending: return "pending"
        case .restricted: return "restricted"
        case .banned: return "banned"
        case .unknown(let value): return value
        }
    }
}
