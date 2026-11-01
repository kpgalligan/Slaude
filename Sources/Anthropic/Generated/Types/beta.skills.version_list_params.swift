// Transformed from `anthropic.types.beta.skills.version_list_params` (version_list_params.py).

import Foundation

public struct BetaSkillsVersionListParams: Codable, Hashable, Sendable {
    /// Number of results to return per page.
    ///
    /// Ranges from `1` to `1000`. Defaults to `20`.
    public var limit: Int??
    /// Optionally set to the `next_page` token from the previous response.
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

    public init(limit: Int?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.limit = limit
        self.page = page
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case betas
        case workspaceID = "workspace_id"
    }
}
