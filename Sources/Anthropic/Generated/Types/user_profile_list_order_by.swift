// Transformed from `anthropic.types.user_profile_list_order_by` (user_profile_list_order_by.py).

import Foundation

public enum UserProfileListOrderBy: OpenEnum, CaseIterable {
    case createdAt
    case name
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileListOrderBy] = [.createdAt, .name]

    public init(rawValue: String) {
        switch rawValue {
        case "created_at": self = .createdAt
        case "name": self = .name
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .createdAt: return "created_at"
        case .name: return "name"
        case .unknown(let value): return value
        }
    }
}
