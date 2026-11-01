// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_search_result_block` (beta_managed_agents_search_result_block.py).

import Foundation

/// A block containing a web search result.
public struct BetaManagedAgentsSearchResultBlock: Codable, Hashable, Sendable {
    /// Citation settings for this search result.
    public var citations: BetaManagedAgentsSearchResultCitations
    /// Array of text content blocks from the search result.
    public var content: [BetaManagedAgentsSearchResultContent]
    /// The URL source of the search result.
    public var source: String
    /// The title of the search result.
    public var title: String
    public var type: String

    public init(citations: BetaManagedAgentsSearchResultCitations, content: [BetaManagedAgentsSearchResultContent], source: String, title: String, type: String = "search_result") {
        self.citations = citations
        self.content = content
        self.source = source
        self.title = title
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citations
        case content
        case source
        case title
        case type
    }
}
