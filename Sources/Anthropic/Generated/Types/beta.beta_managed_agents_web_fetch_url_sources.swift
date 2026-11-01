// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_sources` (beta_managed_agents_web_fetch_url_sources.py).

import Foundation

/// Which sources contribute URLs the web_fetch tool may fetch.
///
/// A key that is null was not set and allows every URL from that source.
public struct BetaManagedAgentsWebFetchURLSources: Codable, Hashable, Sendable {
    /// Which custom tools' results contribute URLs that may be fetched.
    ///
    /// Null when not set, which allows every custom tool's results.
    public var clientToolResults: BetaManagedAgentsWebFetchURLSourceToolFilter?
    /// Which of the web_search and web_fetch tools' results contribute URLs that may be
    /// fetched. Null when not set, which allows both.
    public var serverToolResults: BetaManagedAgentsWebFetchURLSourceToolFilter?
    /// Whether URLs in the text of user messages may be fetched.
    ///
    /// Null when not set, which allows them.
    public var userInput: BetaManagedAgentsWebFetchURLSourceUserInput?

    public init(clientToolResults: BetaManagedAgentsWebFetchURLSourceToolFilter? = nil, serverToolResults: BetaManagedAgentsWebFetchURLSourceToolFilter? = nil, userInput: BetaManagedAgentsWebFetchURLSourceUserInput? = nil) {
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
