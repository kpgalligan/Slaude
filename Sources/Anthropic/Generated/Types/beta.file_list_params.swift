// Transformed from `anthropic.types.beta.file_list_params` (file_list_params.py).

import Foundation

public struct BetaFileListParams: Codable, Hashable, Sendable {
    /// Restrict the result set to Files whose `id` is in this list.
    ///
    /// At most 100 entries (after de-duplication). Mutually exclusive with `page` and
    /// `limit`. When supplied, the response is always a single page (`next_page` is
    /// null). IDs that do not resolve to a visible File — including deleted Files — are
    /// silently omitted.
    public var ids: [String]??
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Opaque page cursor returned in a prior list response's `next_page`.
    ///
    /// Prefixed `page_`.
    public var page: String??
    /// Filter by scope ID.
    ///
    /// Only returns files associated with the specified scope (e.g., a session ID).
    public var scopeID: String?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, scopeID: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.ids = ids
        self.limit = limit
        self.page = page
        self.scopeID = scopeID
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case ids
        case limit
        case page
        case scopeID = "scope_id"
        case betas
        case workspaceID = "workspace_id"
    }
}
