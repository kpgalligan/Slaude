// Transformed from `anthropic.types.user_profile_list_order` (user_profile_list_order.py).

import Foundation

public enum UserProfileListOrder: OpenEnum, CaseIterable {
    case asc
    case desc
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileListOrder] = [.asc, .desc]

    public init(rawValue: String) {
        switch rawValue {
        case "asc": self = .asc
        case "desc": self = .desc
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .asc: return "asc"
        case .desc: return "desc"
        case .unknown(let value): return value
        }
    }
}
