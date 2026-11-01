// Transformed from `anthropic.types.organization.organization_invite` (organization_invite.py).

import Foundation

public struct OrganizationInvite: Codable, Hashable, Sendable {
    /// ID of the Invite.
    public var id: String
    /// RFC 3339 datetime string indicating when the Invite was accepted, or null.
    public var acceptedAt: Date?
    /// Email of the User being invited.
    public var email: String
    /// RFC 3339 datetime string indicating when the Invite expires.
    public var expiresAt: Date
    /// RFC 3339 datetime string indicating when the Invite was created.
    public var invitedAt: Date
    /// RBAC group IDs recorded on the Invite (Claude Enterprise organizations), to be
    /// assigned to the User when the Invite is accepted. `[]` when none.
    public var rbacGroupIDs: [String]
    /// Organization role of the User.
    public var role: OrganizationRole
    /// Status of the Invite.
    public var status: Status
    /// Object type.
    ///
    /// For Invites, this is always `"invite"`.
    public var type: String

    public init(id: String, acceptedAt: Date? = nil, email: String, expiresAt: Date, invitedAt: Date, rbacGroupIDs: [String], role: OrganizationRole, status: Status, type: String = "invite") {
        self.id = id
        self.acceptedAt = acceptedAt
        self.email = email
        self.expiresAt = expiresAt
        self.invitedAt = invitedAt
        self.rbacGroupIDs = rbacGroupIDs
        self.role = role
        self.status = status
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case acceptedAt = "accepted_at"
        case email
        case expiresAt = "expires_at"
        case invitedAt = "invited_at"
        case rbacGroupIDs = "rbac_group_ids"
        case role
        case status
        case type
    }

    public enum Status: OpenEnum, CaseIterable {
        case accepted
        case deleted
        case expired
        case pending
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.accepted, .deleted, .expired, .pending]

        public init(rawValue: String) {
            switch rawValue {
            case "accepted": self = .accepted
            case "deleted": self = .deleted
            case "expired": self = .expired
            case "pending": self = .pending
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .accepted: return "accepted"
            case .deleted: return "deleted"
            case .expired: return "expired"
            case .pending: return "pending"
            case .unknown(let value): return value
            }
        }
    }
}
