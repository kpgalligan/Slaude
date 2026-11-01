// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_search_result_citations_param` (beta_managed_agents_search_result_citations_param.py).

import Foundation

/// Citation settings for a search result.
public struct BetaManagedAgentsSearchResultCitationsParam: Codable, Hashable, Sendable {
    /// Whether citations are enabled for this search result.
    public var enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case enabled
    }
}
