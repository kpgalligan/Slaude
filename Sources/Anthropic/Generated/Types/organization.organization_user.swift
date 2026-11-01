// Transformed from `anthropic.types.organization.organization_user` (organization_user.py).

import Foundation

public struct OrganizationUser: Codable, Hashable, Sendable {
    /// ID of the User.
    public var id: String
    /// RFC 3339 datetime string indicating when the User joined the Organization.
    public var addedAt: Date
    /// Email of the User.
    public var email: String
    /// Name of the User.
    public var name: String
    /// Organization role of the User.
    public var role: OrganizationRole
    /// Object type.
    ///
    /// For Users, this is always `"user"`.
    public var type: String

    public init(id: String, addedAt: Date, email: String, name: String, role: OrganizationRole, type: String = "user") {
        self.id = id
        self.addedAt = addedAt
        self.email = email
        self.name = name
        self.role = role
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case addedAt = "added_at"
        case email
        case name
        case role
        case type
    }
}
