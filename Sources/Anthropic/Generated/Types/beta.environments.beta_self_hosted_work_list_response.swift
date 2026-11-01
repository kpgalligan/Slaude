// Transformed from `anthropic.types.beta.environments.beta_self_hosted_work_list_response` (beta_self_hosted_work_list_response.py).

import Foundation

/// Response when listing work items with cursor-based pagination.
public struct BetaSelfHostedWorkListResponse: Codable, Hashable, Sendable {
    /// List of work items
    public var data: [BetaSelfHostedWork]
    /// Opaque cursor for fetching the next page of results
    public var nextPage: String?

    public init(data: [BetaSelfHostedWork], nextPage: String? = nil) {
        self.data = data
        self.nextPage = nextPage
    }

    enum CodingKeys: String, CodingKey {
        case data
        case nextPage = "next_page"
    }
}
