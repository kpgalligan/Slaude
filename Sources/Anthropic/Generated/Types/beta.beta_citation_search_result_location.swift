// Transformed from `anthropic.types.beta.beta_citation_search_result_location` (beta_citation_search_result_location.py).

import Foundation

public struct BetaCitationSearchResultLocation: Codable, Hashable, Sendable {
    /// The full text of the cited block range, concatenated.
    ///
    /// Always equals the contents of `content[start_block_index:end_block_index]`
    /// joined together. The text block is the minimal citable unit; this field is never
    /// a substring of a single block. Not counted toward output tokens, and not counted
    /// toward input tokens when sent back in subsequent turns.
    public var citedText: String
    /// Exclusive 0-based end index of the cited block range in the source's `content`
    /// array.
    ///
    /// Always greater than `start_block_index`; a single-block citation has
    /// `end_block_index = start_block_index + 1`.
    public var endBlockIndex: Int
    /// 0-based index of the cited search result among all `search_result` content
    /// blocks in the request, in the order they appear across messages and tool
    /// results.
    ///
    /// Counted separately from `document_index`; server-side web search results are not
    /// included in this count.
    public var searchResultIndex: Int
    public var source: String
    /// 0-based index of the first cited block in the source's `content` array.
    public var startBlockIndex: Int
    public var title: String?
    public var type: String

    public init(citedText: String, endBlockIndex: Int, searchResultIndex: Int, source: String, startBlockIndex: Int, title: String? = nil, type: String = "search_result_location") {
        self.citedText = citedText
        self.endBlockIndex = endBlockIndex
        self.searchResultIndex = searchResultIndex
        self.source = source
        self.startBlockIndex = startBlockIndex
        self.title = title
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case endBlockIndex = "end_block_index"
        case searchResultIndex = "search_result_index"
        case source
        case startBlockIndex = "start_block_index"
        case title
        case type
    }
}
