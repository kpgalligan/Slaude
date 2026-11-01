// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_all` (beta_managed_agents_web_fetch_url_source_all.py).

import Foundation

/// Every URL from this source may be fetched. This is the default.
public struct BetaManagedAgentsWebFetchURLSourceAll: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
