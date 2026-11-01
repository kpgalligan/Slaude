// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_except_param` (beta_managed_agents_web_fetch_url_source_except_param.py).

import Foundation

/// Every tool's results contribute URLs that may be fetched, except the named tools' results.
public struct BetaManagedAgentsWebFetchURLSourceExceptParam: Codable, Hashable, Sendable {
    /// The tools whose results do not contribute.
    ///
    /// Between 1 and 128 entries, each with a different name. An empty list is
    /// rejected; use "all" to leave out no tool's results.
    public var tools: [BetaManagedAgentsWebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [BetaManagedAgentsWebFetchURLSourceToolReferenceParam], type: String = "except") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
