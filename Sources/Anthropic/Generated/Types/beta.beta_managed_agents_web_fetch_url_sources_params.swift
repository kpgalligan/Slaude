// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_sources_params` (beta_managed_agents_web_fetch_url_sources_params.py).

import Foundation

/// Which sources contribute URLs the web_fetch tool may fetch.
///
/// When web_fetch is limited to URLs the conversation has already shown the model (in a user message, a custom tool's result, or an earlier web_search or web_fetch result), each key narrows one of those sources and defaults to "all". Setting all three keys to "none" is rejected.
public struct BetaManagedAgentsWebFetchURLSourcesParams: Codable, Hashable, Sendable {
    /// Which custom tools' results contribute URLs that may be fetched: "all" (the
    /// default), "none", or an only or except list. Each name in a list must be a
    /// custom tool in the same tools array.
    public var clientToolResults: BetaManagedAgentsWebFetchURLSourceToolFilterParams??
    /// Which of the web_search and web_fetch tools' results contribute URLs that may be
    /// fetched: "all" (the default), "none", or an only or except list. Each name in a
    /// list must be "web_search" or "web_fetch".
    public var serverToolResults: BetaManagedAgentsWebFetchURLSourceToolFilterParams??
    /// Whether URLs in the text of user messages may be fetched: "all" (the default) or
    /// "none".
    public var userInput: BetaManagedAgentsWebFetchURLSourceUserInputParams??

    public init(clientToolResults: BetaManagedAgentsWebFetchURLSourceToolFilterParams?? = nil, serverToolResults: BetaManagedAgentsWebFetchURLSourceToolFilterParams?? = nil, userInput: BetaManagedAgentsWebFetchURLSourceUserInputParams?? = nil) {
        self.clientToolResults = clientToolResults
        self.serverToolResults = serverToolResults
        self.userInput = userInput
    }

    enum CodingKeys: String, CodingKey {
        case clientToolResults = "client_tool_results"
        case serverToolResults = "server_tool_results"
        case userInput = "user_input"
    }
}
