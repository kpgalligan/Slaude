// Transformed from `anthropic.types.beta.beta_server_tool_usage` (beta_server_tool_usage.py).

import Foundation

public struct BetaServerToolUsage: Codable, Hashable, Sendable {
    /// The number of web fetch tool requests.
    public var webFetchRequests: Int
    /// The number of web search tool requests.
    public var webSearchRequests: Int

    public init(webFetchRequests: Int, webSearchRequests: Int) {
        self.webFetchRequests = webFetchRequests
        self.webSearchRequests = webSearchRequests
    }

    enum CodingKeys: String, CodingKey {
        case webFetchRequests = "web_fetch_requests"
        case webSearchRequests = "web_search_requests"
    }
}
