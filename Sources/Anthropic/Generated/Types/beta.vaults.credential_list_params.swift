// Transformed from `anthropic.types.beta.vaults.credential_list_params` (credential_list_params.py).

import Foundation

public struct CredentialListParams: Codable, Hashable, Sendable {
    /// Whether to include archived credentials in the results. Defaults to `false`.
    public var includeArchived: Bool?
    /// Maximum number of credentials to return per page. Defaults to 20, maximum 100.
    public var limit: Int?
    /// The `next_page` value from a previous
    /// [List Credentials](https://platform.claude.com/docs/en/api/beta/vaults/credentials/list)
    /// response, to get the next page. Leave it out to get the first page.
    public var page: String?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
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
