// Transformed from `anthropic.types.organization.api_key_list_params` (api_key_list_params.py).

import Foundation

public struct APIKeyListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeID: String?
    /// Filter by the ID of the User who created the object.
    public var createdByUserID: String??
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Filter by API key status.
    public var status: Status??
    /// Filter by Workspace ID.
    public var workspaceID: String??

    public init(afterID: String? = nil, beforeID: String? = nil, createdByUserID: String?? = nil, limit: Int? = nil, status: Status?? = nil, workspaceID: String?? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.createdByUserID = createdByUserID
        self.limit = limit
        self.status = status
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case createdByUserID = "created_by_user_id"
        case limit
        case status
        case workspaceID = "workspace_id"
    }

    public enum Status: OpenEnum, CaseIterable {
        case active
        case archived
        case expired
        case inactive
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.active, .archived, .expired, .inactive]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "archived": self = .archived
            case "expired": self = .expired
            case "inactive": self = .inactive
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .archived: return "archived"
            case .expired: return "expired"
            case .inactive: return "inactive"
            case .unknown(let value): return value
            }
        }
    }
}
