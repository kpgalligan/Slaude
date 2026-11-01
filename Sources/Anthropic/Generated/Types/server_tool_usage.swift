// Transformed from `anthropic.types.server_tool_usage` (server_tool_usage.py).

import Foundation

public struct ServerToolUsage: Codable, Hashable, Sendable {
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
