// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_none` (beta_managed_agents_web_fetch_url_source_none.py).

import Foundation

/// This source contributes no URLs that may be fetched.
public struct BetaManagedAgentsWebFetchURLSourceNone: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
