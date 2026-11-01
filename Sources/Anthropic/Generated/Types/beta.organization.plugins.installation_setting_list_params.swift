// Transformed from `anthropic.types.beta.organization.plugins.installation_setting_list_params` (installation_setting_list_params.py).

import Foundation

public struct InstallationSettingListParams: Codable, Hashable, Sendable {
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `100`.
    public var limit: Int?
    /// For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    /// parent organization's linked organizations: a child organization of that parent
    /// to read instead of the organization the key was created in, given as the
    /// organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    /// 400; an organization that is not a child of the key's parent, or where the
    /// Plugins API is not available, returns a 404. Any other key may pass only its own
    /// organization's ID here; another organization returns a 404.
    public var organizationID: String??
    /// Optionally set to the `next_page` token from the previous response.
    public var page: String??
    /// Only settings for this kind of target: `organization` (the organization-wide
    /// setting) or `rbac_group` (an RBAC Group's).
    public var targetType: TargetType??
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: TargetType?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.organizationID = organizationID
        self.page = page
        self.targetType = targetType
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case organizationID = "organization_id"
        case page
        case targetType = "target_type"
        case betas
    }

    public enum TargetType: OpenEnum, CaseIterable {
        case organization
        case rbacGroup
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TargetType] = [.organization, .rbacGroup]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "rbac_group": self = .rbacGroup
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .rbacGroup: return "rbac_group"
            case .unknown(let value): return value
            }
        }
    }
}
