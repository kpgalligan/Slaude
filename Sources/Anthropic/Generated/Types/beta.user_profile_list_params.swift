// Transformed from `anthropic.types.beta.user_profile_list_params` (user_profile_list_params.py).

import Foundation

public struct BetaUserProfileListParams: Codable, Hashable, Sendable {
    /// The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    public var limit: Int?
    /// The sort direction, applied to the field that `order_by` selects.
    ///
    /// Defaults to `desc`.
    ///
    /// - `asc` - Oldest first when `order_by` is `created_at`, or names in ascending
    ///   order when `order_by` is `name`.
    /// - `desc` - Newest first when `order_by` is `created_at`, or names in descending
    ///   order when `order_by` is `name`. This is the default.
    public var order: Order?
    /// The field to sort user profiles by, in the direction that `order` sets.
    ///
    /// Defaults to `created_at`.
    ///
    /// - `created_at` - Sort by when each user profile was created. This is the
    ///   default.
    /// - `name` - Sort by `name`, ignoring the case of ASCII letters. Profiles without
    ///   a name come last in either direction.
    public var orderBy: OrderBy?
    /// The cursor for the page to return, taken from `next_page` in a previous
    /// response.
    ///
    /// Leave it out to get the first page.
    public var page: String?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(limit: Int? = nil, order: Order? = nil, orderBy: OrderBy? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.limit = limit
        self.order = order
        self.orderBy = orderBy
        self.page = page
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case order
        case orderBy = "order_by"
        case page
        case betas
        case workspaceId = "workspace_id"
    }

    public enum Order: OpenEnum, CaseIterable {
        case asc
        case desc
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Order] = [.asc, .desc]

        public init(rawValue: String) {
            switch rawValue {
            case "asc": self = .asc
            case "desc": self = .desc
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .asc: return "asc"
            case .desc: return "desc"
            case .unknown(let value): return value
            }
        }
    }

    public enum OrderBy: OpenEnum, CaseIterable {
        case createdAt
        case name
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OrderBy] = [.createdAt, .name]

        public init(rawValue: String) {
            switch rawValue {
            case "created_at": self = .createdAt
            case "name": self = .name
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .createdAt: return "created_at"
            case .name: return "name"
            case .unknown(let value): return value
            }
        }
    }
}
