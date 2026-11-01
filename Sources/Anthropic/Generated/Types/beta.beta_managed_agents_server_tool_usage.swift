// Transformed from `anthropic.types.beta.beta_managed_agents_server_tool_usage` (beta_managed_agents_server_tool_usage.py).

import Foundation

/// Cumulative count of server-executed tool invocations, broken down by tool.
public struct BetaManagedAgentsServerToolUsage: Codable, Hashable, Sendable {
    /// Number of server-executed web fetch requests.
    public var webFetchRequests: Int?
    /// Number of server-executed web search requests.
    public var webSearchRequests: Int?

    public init(webFetchRequests: Int? = nil, webSearchRequests: Int? = nil) {
        self.webFetchRequests = webFetchRequests
        self.webSearchRequests = webSearchRequests
    }

    enum CodingKeys: String, CodingKey {
        case webFetchRequests = "web_fetch_requests"
        case webSearchRequests = "web_search_requests"
    }
}
