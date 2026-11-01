// Transformed from `anthropic.types.organization.federation.rule_list_params` (rule_list_params.py).

import Foundation

public struct RuleListParams: Codable, Hashable, Sendable {
    /// Include archived resources. Defaults to false.
    public var includeArchived: Bool?
    /// Filter to rules referencing this federation issuer.
    public var issuerID: String??
    /// Number of results per page.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??

    public init(includeArchived: Bool? = nil, issuerID: String?? = nil, limit: Int? = nil, page: String?? = nil) {
        self.includeArchived = includeArchived
        self.issuerID = issuerID
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case includeArchived = "include_archived"
        case issuerID = "issuer_id"
        case limit
        case page
    }
}
