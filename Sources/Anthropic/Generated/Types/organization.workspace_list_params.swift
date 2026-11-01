// Transformed from `anthropic.types.organization.workspace_list_params` (workspace_list_params.py).

import Foundation

public struct WorkspaceListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeID: String?
    /// Whether to include Workspaces that have been archived in the response
    public var includeArchived: Bool?
    /// Whether to include the organization's default Workspace in the response
    public var includeDefault: Bool?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?

    public init(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.includeArchived = includeArchived
        self.includeDefault = includeDefault
        self.limit = limit
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case includeArchived = "include_archived"
        case includeDefault = "include_default"
        case limit
    }
}
