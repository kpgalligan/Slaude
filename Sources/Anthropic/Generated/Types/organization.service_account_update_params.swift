// Transformed from `anthropic.types.organization.service_account_update_params` (service_account_update_params.py).

import Foundation

public struct ServiceAccountUpdateParams: Codable, Hashable, Sendable {
    /// Replaces the description.
    ///
    /// Omit to leave unchanged; send `null` to clear (the field is stored as an empty
    /// string).
    public var description: String??
    /// Replaces the org-level role. Omit or send `null` to leave unchanged.
    public var organizationRole: OrganizationRole??

    public init(description: String?? = nil, organizationRole: OrganizationRole?? = nil) {
        self.description = description
        self.organizationRole = organizationRole
    }

    enum CodingKeys: String, CodingKey {
        case description
        case organizationRole = "organization_role"
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
