// Transformed from `anthropic.types.beta.skill_list_params` (skill_list_params.py).

import Foundation

public struct BetaSkillListParams: Codable, Hashable, Sendable {
    /// Number of results to return per page.
    ///
    /// Ranges from `1` to `1000`. Defaults to `20`.
    public var limit: Int?
    /// Pagination token for fetching a specific page of results.
    ///
    /// Pass the value from a previous response's `next_page` field to get the next page
    /// of results.
    public var page: String??
    /// Filter skills by source.
    ///
    /// If provided, only skills from the specified source will be returned:
    ///
    /// - `"custom"`: only return user-created skills
    /// - `"anthropic"`: only return Anthropic-created skills
    public var source: String??
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

    public init(limit: Int? = nil, page: String?? = nil, source: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.limit = limit
        self.page = page
        self.source = source
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case source
        case betas
        case workspaceID = "workspace_id"
    }
}
