// Transformed from `anthropic.types.organization.invite_create_params` (invite_create_params.py).

import Foundation

public struct InviteCreateParams: Codable, Hashable, Sendable {
    /// Email of the User.
    public var email: String
    /// Role for the invited User.
    ///
    /// The accepted values depend on the organization type. Console and API
    /// organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    /// `admin` cannot be assigned through the API. Claude Enterprise organizations
    /// accept `user` and `managed`; inviting with the `managed` role requires the
    /// `write:rbac_groups` scope in addition to `write:members`.
    public var role: Role
    /// RBAC group IDs to assign to the User when the Invite is accepted.
    ///
    /// A non-empty array is accepted only for a Claude Enterprise organization with
    /// RBAC groups, and requires the key to carry the `write:rbac_groups` scope.
    public var rbacGroupIds: [String]?

    public init(email: String, role: Role, rbacGroupIds: [String]? = nil) {
        self.email = email
        self.role = role
        self.rbacGroupIds = rbacGroupIds
    }

    enum CodingKeys: String, CodingKey {
        case email
        case role
        case rbacGroupIds = "rbac_group_ids"
    }

    public enum Role: OpenEnum, CaseIterable {
        case billing
        case claudeCodeUser
        case developer
        case managed
        case user
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Role] = [.billing, .claudeCodeUser, .developer, .managed, .user]

        public init(rawValue: String) {
            switch rawValue {
            case "billing": self = .billing
            case "claude_code_user": self = .claudeCodeUser
            case "developer": self = .developer
            case "managed": self = .managed
            case "user": self = .user
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .billing: return "billing"
            case .claudeCodeUser: return "claude_code_user"
            case .developer: return "developer"
            case .managed: return "managed"
            case .user: return "user"
            case .unknown(let value): return value
            }
        }
    }
}
