// Transformed from `anthropic.types.user_profile_program_status` (user_profile_program_status.py).

import Foundation

public enum UserProfileProgramStatus: OpenEnum, CaseIterable {
    case active
    case pending
    case rejected
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileProgramStatus] = [.active, .pending, .rejected]

    public init(rawValue: String) {
        switch rawValue {
        case "active": self = .active
        case "pending": self = .pending
        case "rejected": self = .rejected
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .active: return "active"
        case .pending: return "pending"
        case .rejected: return "rejected"
        case .unknown(let value): return value
        }
    }
}
