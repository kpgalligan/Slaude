// Transformed from `anthropic.types.beta.organization.plugin_marketplace_list_params` (plugin_marketplace_list_params.py).

import Foundation

public struct PluginMarketplaceListParams: Codable, Hashable, Sendable {
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    /// parent organization's linked organizations: a child organization of that parent
    /// to read instead of the organization the key was created in, given as the
    /// organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    /// 400; an organization that is not a child of the key's parent, or where the
    /// Plugins API is not available, returns a 404. Any other key may pass only its own
    /// organization's ID here; another organization returns a 404.
    public var organizationId: String??
    /// `organization` for the organization's plugin marketplaces, `user` for members'
    /// personal plugin marketplaces.
    public var ownerType: OwnerType??
    /// Optionally set to the `next_page` token from the previous response.
    public var page: String??
    /// Only plugin marketplaces with this `source`: `manual` for those whose Plugins
    /// are uploaded; `github`, `gitlab` or `public_git` for those synchronized from a
    /// Git repository. `directory` (Anthropic's catalog) is never listed here.
    public var source: Source??
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, organizationId: String?? = nil, ownerType: OwnerType?? = nil, page: String?? = nil, source: Source?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.organizationId = organizationId
        self.ownerType = ownerType
        self.page = page
        self.source = source
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case organizationId = "organization_id"
        case ownerType = "owner_type"
        case page
        case source
        case betas
    }

    public enum OwnerType: OpenEnum, CaseIterable {
        case organization
        case user
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OwnerType] = [.organization, .user]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "user": self = .user
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .user: return "user"
            case .unknown(let value): return value
            }
        }
    }

    public enum Source: OpenEnum, CaseIterable {
        case directory
        case github
        case gitlab
        case manual
        case publicGit
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Source] = [.directory, .github, .gitlab, .manual, .publicGit]

        public init(rawValue: String) {
            switch rawValue {
            case "directory": self = .directory
            case "github": self = .github
            case "gitlab": self = .gitlab
            case "manual": self = .manual
            case "public_git": self = .publicGit
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .directory: return "directory"
            case .github: return "github"
            case .gitlab: return "gitlab"
            case .manual: return "manual"
            case .publicGit: return "public_git"
            case .unknown(let value): return value
            }
        }
    }
}
