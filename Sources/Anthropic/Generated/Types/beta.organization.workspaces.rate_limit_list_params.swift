// Transformed from `anthropic.types.beta.organization.workspaces.rate_limit_list_params` (rate_limit_list_params.py).

import Foundation

public struct BetaOrganizationWorkspacesRateLimitListParams: Codable, Hashable, Sendable {
    /// Filter by group type.
    public var groupType: GroupType??
    /// Also list the limiter values the workspace inherits from the organization,
    /// including groups with no workspace-level override.
    public var includeInherited: Bool?
    /// Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    /// When omitted, every remaining entry is returned in a single page and `next_page`
    /// is `null`.
    public var limit: Int??
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??

    public init(groupType: GroupType?? = nil, includeInherited: Bool? = nil, limit: Int?? = nil, page: String?? = nil) {
        self.groupType = groupType
        self.includeInherited = includeInherited
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case groupType = "group_type"
        case includeInherited = "include_inherited"
        case limit
        case page
    }

    public enum GroupType: OpenEnum, CaseIterable {
        case batch
        case files
        case modelGroup
        case skills
        case tokenCount
        case webSearch
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [GroupType] = [.batch, .files, .modelGroup, .skills, .tokenCount, .webSearch]

        public init(rawValue: String) {
            switch rawValue {
            case "batch": self = .batch
            case "files": self = .files
            case "model_group": self = .modelGroup
            case "skills": self = .skills
            case "token_count": self = .tokenCount
            case "web_search": self = .webSearch
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .batch: return "batch"
            case .files: return "files"
            case .modelGroup: return "model_group"
            case .skills: return "skills"
            case .tokenCount: return "token_count"
            case .webSearch: return "web_search"
            case .unknown(let value): return value
            }
        }
    }
}
