// Transformed from `anthropic.types.beta.organization.rate_limit_list_params` (rate_limit_list_params.py).

import Foundation

public struct BetaOrganizationRateLimitListParams: Codable, Hashable, Sendable {
    /// Filter by group type.
    public var groupType: GroupType??
    /// Maximum number of items to return per page. Ranges from `1` to `1000`.
    ///
    /// When omitted, every remaining entry is returned in a single page and `next_page`
    /// is `null`.
    public var limit: Int??
    /// Filter to the single entry containing this model.
    ///
    /// Accepts full model names and aliases. Returns 404 if the model is not found or
    /// has no rate limits for this organization.
    public var model: String??
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??

    public init(groupType: GroupType?? = nil, limit: Int?? = nil, model: String?? = nil, page: String?? = nil) {
        self.groupType = groupType
        self.limit = limit
        self.model = model
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case groupType = "group_type"
        case limit
        case model
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
