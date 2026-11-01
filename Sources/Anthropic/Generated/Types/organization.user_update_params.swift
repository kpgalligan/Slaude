// Transformed from `anthropic.types.organization.user_update_params` (user_update_params.py).

import Foundation

public struct UserUpdateParams: Codable, Hashable, Sendable {
    /// New role for the User.
    ///
    /// The accepted values depend on the organization type. Console and API
    /// organizations accept `user`, `developer`, `billing`, and `claude_code_user`;
    /// `admin` cannot be assigned through the API. Claude Enterprise organizations
    /// accept `user` and `managed`; changing a User's role to `managed` requires the
    /// `write:rbac_groups` scope in addition to `write:members`.
    public var role: Role

    public init(role: Role) {
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case role
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
