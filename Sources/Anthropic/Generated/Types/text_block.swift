// Transformed from `anthropic.types.text_block` (text_block.py).

import Foundation

public struct TextBlock: Codable, Hashable, Sendable {
    /// Citations supporting the text block.
    ///
    /// The type of citation returned will depend on the type of document being cited.
    /// Citing a PDF results in `page_location`, plain text results in `char_location`,
    /// and content document results in `content_block_location`.
    public var citations: [TextCitation]?
    public var text: String
    public var type: String

    public init(citations: [TextCitation]? = nil, text: String, type: String = "text") {
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
