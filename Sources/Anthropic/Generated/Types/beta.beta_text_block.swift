// Transformed from `anthropic.types.beta.beta_text_block` (beta_text_block.py).

import Foundation

public struct BetaTextBlock: Codable, Hashable, Sendable {
    /// Citations supporting the text block.
    ///
    /// The type of citation returned will depend on the type of document being cited.
    /// Citing a PDF results in `page_location`, plain text results in `char_location`,
    /// and content document results in `content_block_location`.
    public var citations: [BetaTextCitation]?
    public var text: String
    public var type: String

    public init(citations: [BetaTextCitation]? = nil, text: String, type: String = "text") {
        self.citations = citations
        self.text = text
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citations
        case text
        case type
    }
}
