// Transformed from `anthropic.types.organization_role` (organization_role.py).

import Foundation

public enum OrganizationRole: OpenEnum, CaseIterable {
    case admin
    case billing
    case claudeCodeUser
    case developer
    case managed
    case membershipAdmin
    case owner
    case primaryOwner
    case user
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [OrganizationRole] = [.admin, .billing, .claudeCodeUser, .developer, .managed, .membershipAdmin, .owner, .primaryOwner, .user]

    public init(rawValue: String) {
        switch rawValue {
        case "admin": self = .admin
        case "billing": self = .billing
        case "claude_code_user": self = .claudeCodeUser
        case "developer": self = .developer
        case "managed": self = .managed
        case "membership_admin": self = .membershipAdmin
        case "owner": self = .owner
        case "primary_owner": self = .primaryOwner
        case "user": self = .user
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .admin: return "admin"
        case .billing: return "billing"
        case .claudeCodeUser: return "claude_code_user"
        case .developer: return "developer"
        case .managed: return "managed"
        case .membershipAdmin: return "membership_admin"
        case .owner: return "owner"
        case .primaryOwner: return "primary_owner"
        case .user: return "user"
        case .unknown(let value): return value
        }
    }
}
