// Transformed from `anthropic.types.beta.organization.beta_rbac_role` (beta_rbac_role.py).

import Foundation

public struct BetaRBACRole: Codable, Hashable, Sendable {
    /// ID of the RBAC Role.
    public var id: String
    /// RFC 3339 datetime string indicating when the RBAC Role was created.
    public var createdAt: Date
    /// Name of the RBAC Role.
    ///
    /// For a role created by Anthropic, this name can differ from the label claude.ai
    /// shows, and Anthropic may change the name. To keep a lasting reference to a role,
    /// store its `id`.
    public var displayName: String
    /// Object type.
    ///
    /// For RBAC Roles, this is always `"rbac_role"`.
    public var type: String
    /// RFC 3339 datetime string indicating when the RBAC Role was last updated.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, displayName: String, type: String = "rbac_role", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.displayName = displayName
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case displayName = "display_name"
        case type
        case updatedAt = "updated_at"
    }
}
