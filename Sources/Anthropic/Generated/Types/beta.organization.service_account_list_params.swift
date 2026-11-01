// Transformed from `anthropic.types.beta.organization.service_account_list_params` (service_account_list_params.py).

import Foundation

public struct BetaOrganizationServiceAccountListParams: Codable, Hashable, Sendable {
    /// Include archived resources. Defaults to false.
    public var includeArchived: Bool?
    /// Number of results per page.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case includeArchived = "include_archived"
        case limit
        case page
        case betas
    }
}
