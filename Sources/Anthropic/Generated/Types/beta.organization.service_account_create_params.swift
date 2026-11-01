// Transformed from `anthropic.types.beta.organization.service_account_create_params` (service_account_create_params.py).

import Foundation

public struct BetaOrganizationServiceAccountCreateParams: Codable, Hashable, Sendable {
    /// Slug identifier (lowercase, digits, hyphens).
    ///
    /// Unique within the organization; a duplicate name returns 409.
    public var name: String
    /// Optional free-text description.
    public var description: String??
    /// Org-level role. Defaults to `developer`.
    public var organizationRole: OrganizationRole?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(name: String, description: String?? = nil, organizationRole: OrganizationRole? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.name = name
        self.description = description
        self.organizationRole = organizationRole
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case organizationRole = "organization_role"
        case betas
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
