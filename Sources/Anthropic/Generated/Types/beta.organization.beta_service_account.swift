// Transformed from `anthropic.types.beta.organization.beta_service_account` (beta_service_account.py).

import Foundation

/// Named non-human identity within the caller's organization.
///
/// A service account is a pure identity: name + org. Authorization lives on
/// whatever references it (federation rules).
public struct BetaServiceAccount: Codable, Hashable, Sendable {
    /// Tagged ID of the service account.
    public var id: String
    /// If set, this service account is archived.
    public var archivedAt: Date?
    /// Tagged ID (`user_`/`svac_`) of the actor that archived this service account.
    public var archivedByActorID: String?
    /// When this service account was created.
    public var createdAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that created this service account.
    public var createdByActorID: String?
    /// Optional free-text description.
    public var description: String?
    /// Admin-chosen slug identifier.
    public var name: String
    /// Org-level role.
    ///
    /// A federation rule may only be created or retargeted to grant `org:admin` scope
    /// when this is `admin`. A rule granting `org:admin` whose target is later demoted
    /// to `developer` is rejected at token exchange. Rules granting `org:admin` are
    /// managed in the Console.
    public var organizationRole: OrganizationRole
    public var type: String
    /// When this service account was last updated.
    public var updatedAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that last updated this service account.
    public var updatedByActorID: String?

    public init(id: String, archivedAt: Date? = nil, archivedByActorID: String? = nil, createdAt: Date, createdByActorID: String? = nil, description: String? = nil, name: String, organizationRole: OrganizationRole, type: String = "service_account", updatedAt: Date, updatedByActorID: String? = nil) {
        self.id = id
        self.archivedAt = archivedAt
        self.archivedByActorID = archivedByActorID
        self.createdAt = createdAt
        self.createdByActorID = createdByActorID
        self.description = description
        self.name = name
        self.organizationRole = organizationRole
        self.type = type
        self.updatedAt = updatedAt
        self.updatedByActorID = updatedByActorID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case archivedByActorID = "archived_by_actor_id"
        case createdAt = "created_at"
        case createdByActorID = "created_by_actor_id"
        case description
        case name
        case organizationRole = "organization_role"
        case type
        case updatedAt = "updated_at"
        case updatedByActorID = "updated_by_actor_id"
    }

    public enum OrganizationRole: OpenEnum, CaseIterable {
        case admin
        case developer
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OrganizationRole] = [.admin, .developer]

        public init(rawValue: String) {
            switch rawValue {
            case "admin": self = .admin
            case "developer": self = .developer
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .admin: return "admin"
            case .developer: return "developer"
            case .unknown(let value): return value
            }
        }
    }
}
