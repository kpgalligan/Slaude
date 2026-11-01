// Transformed from `anthropic.types.user_profile_access_type` (user_profile_access_type.py).

import Foundation

public enum UserProfileAccessType: OpenEnum, CaseIterable {
    case application
    case passthrough
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileAccessType] = [.application, .passthrough]

    public init(rawValue: String) {
        switch rawValue {
        case "application": self = .application
        case "passthrough": self = .passthrough
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .application: return "application"
        case .passthrough: return "passthrough"
        case .unknown(let value): return value
        }
    }
}
