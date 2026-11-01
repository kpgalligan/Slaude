// Transformed from `anthropic.types.beta.environment_list_params` (environment_list_params.py).

import Foundation

public struct EnvironmentListParams: Codable, Hashable, Sendable {
    /// Include archived environments in the response
    public var includeArchived: Bool?
    /// Maximum number of environments to return
    public var limit: Int?
    /// Opaque cursor from previous response for pagination.
    ///
    /// Pass the `next_page` value from the previous response.
    public var page: String??
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

    public init(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case includeArchived = "include_archived"
        case limit
        case page
        case betas
        case workspaceID = "workspace_id"
    }
}
