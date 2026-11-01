// Transformed from `anthropic.types.messages.batch_list_params` (batch_list_params.py).

import Foundation

public struct BatchListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeID: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, workspaceID: String? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.limit = limit
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case limit
        case workspaceID = "workspace_id"
    }
}
