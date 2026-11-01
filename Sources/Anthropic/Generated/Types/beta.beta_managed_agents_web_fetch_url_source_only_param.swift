// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_only_param` (beta_managed_agents_web_fetch_url_source_only_param.py).

import Foundation

/// Only the named tools' results contribute URLs that may be fetched.
public struct BetaManagedAgentsWebFetchURLSourceOnlyParam: Codable, Hashable, Sendable {
    /// The tools whose results contribute.
    ///
    /// Between 1 and 128 entries, each with a different name. An empty list is
    /// rejected; use "none" to allow no tool's results.
    public var tools: [BetaManagedAgentsWebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [BetaManagedAgentsWebFetchURLSourceToolReferenceParam], type: String = "only") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
