// Transformed from `anthropic.types.beta.organization.beta_analytics_server_tool_use` (beta_analytics_server_tool_use.py).

import Foundation

public struct BetaAnalyticsServerToolUse: Codable, Hashable, Sendable {
    /// The number of web search requests made.
    public var webSearchRequests: Int

    public init(webSearchRequests: Int) {
        self.webSearchRequests = webSearchRequests
    }

    enum CodingKeys: String, CodingKey {
        case webSearchRequests = "web_search_requests"
    }
}
