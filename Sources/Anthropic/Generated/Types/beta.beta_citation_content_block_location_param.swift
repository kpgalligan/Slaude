// Transformed from `anthropic.types.beta.beta_citation_content_block_location_param` (beta_citation_content_block_location_param.py).

import Foundation

public struct BetaCitationContentBlockLocationParam: Codable, Hashable, Sendable {
    /// The full text of the cited block range, concatenated.
    ///
    /// Always equals the contents of `content[start_block_index:end_block_index]`
    /// joined together. The text block is the minimal citable unit; this field is never
    /// a substring of a single block. Not counted toward output tokens, and not counted
    /// toward input tokens when sent back in subsequent turns.
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    /// Exclusive 0-based end index of the cited block range in the source's `content`
    /// array.
    ///
    /// Always greater than `start_block_index`; a single-block citation has
    /// `end_block_index = start_block_index + 1`.
    public var endBlockIndex: Int
    /// 0-based index of the first cited block in the source's `content` array.
    public var startBlockIndex: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endBlockIndex: Int, startBlockIndex: Int, type: String = "content_block_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endBlockIndex = endBlockIndex
        self.startBlockIndex = startBlockIndex
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endBlockIndex = "end_block_index"
        case startBlockIndex = "start_block_index"
        case type
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(citedText, forKey: .citedText)
        try c.encode(documentIndex, forKey: .documentIndex)
        try c.encode(documentTitle, forKey: .documentTitle)
        try c.encode(endBlockIndex, forKey: .endBlockIndex)
        try c.encode(startBlockIndex, forKey: .startBlockIndex)
        try c.encode(type, forKey: .type)
    }
}
