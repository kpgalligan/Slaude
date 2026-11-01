// Transformed from `anthropic.types.beta.organization.beta_rbac_group` (beta_rbac_group.py).

import Foundation

public struct BetaRBACGroup: Codable, Hashable, Sendable {
    /// ID of the RBAC Group.
    public var id: String
    /// RFC 3339 timestamp of when the RBAC Group was created.
    public var createdAt: Date
    /// Name of the RBAC Group. Not uniqueness-enforced.
    public var name: String
    /// RBAC Role IDs attached to this RBAC Group.
    ///
    /// Role attachment is managed in the admin settings and is read-only on this API.
    /// `null` means role data was temporarily unavailable — retry to distinguish from
    /// an empty list.
    public var roleIDs: [String]?
    /// How the RBAC Group was created: `"direct"` for groups created directly (for
    /// example, in the organization's admin settings), `"scim"` for groups provisioned
    /// by the identity provider.
    public var sourceType: SourceType
    /// Object type.
    ///
    /// For RBAC Groups, this is always `"rbac_group"`.
    public var type: String
    /// RFC 3339 timestamp of when the RBAC Group was last updated.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, name: String, roleIDs: [String]? = nil, sourceType: SourceType, type: String = "rbac_group", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.roleIDs = roleIDs
        self.sourceType = sourceType
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case name
        case roleIDs = "role_ids"
        case sourceType = "source_type"
        case type
        case updatedAt = "updated_at"
    }

    public enum SourceType: OpenEnum, CaseIterable {
        case direct
        case scim
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [SourceType] = [.direct, .scim]

        public init(rawValue: String) {
            switch rawValue {
            case "direct": self = .direct
            case "scim": self = .scim
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .direct: return "direct"
            case .scim: return "scim"
            case .unknown(let value): return value
            }
        }
    }
}
