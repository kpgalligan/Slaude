// Transformed from `anthropic.types.beta.organization.federation.rules.workspace_list_params` (workspace_list_params.py).

import Foundation

public struct BetaOrganizationFederationRulesWorkspaceListParams: Codable, Hashable, Sendable {
    /// Number of results per page.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.page = page
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case betas
    }
}
