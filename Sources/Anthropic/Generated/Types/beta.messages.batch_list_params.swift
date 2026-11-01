// Transformed from `anthropic.types.beta.messages.batch_list_params` (batch_list_params.py).

import Foundation

public struct BetaMessagesBatchListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterId: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeId: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
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

    public init(afterId: String? = nil, beforeId: String? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.afterId = afterId
        self.beforeId = beforeId
        self.limit = limit
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case afterId = "after_id"
        case beforeId = "before_id"
        case limit
        case betas
        case workspaceId = "workspace_id"
    }
}
