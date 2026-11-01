// Transformed from `anthropic.types.document_block` (document_block.py).

import Foundation

public struct DocumentBlock: Codable, Hashable, Sendable {
    /// Citation configuration for the document
    public var citations: CitationsConfig?
    public var source: DocumentBlock.Source
    /// The title of the document
    public var title: String?
    public var type: String

    public init(citations: CitationsConfig? = nil, source: DocumentBlock.Source, title: String? = nil, type: String = "document") {
        self.citations = citations
        self.source = source
        self.title = title
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citations
        case source
        case title
        case type
    }
}

extension DocumentBlock {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(Base64PDFSource)
        case text(PlainTextSource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try Base64PDFSource(from: decoder))
            case "text": self = .text(try PlainTextSource(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .base64(let v): try v.encode(to: encoder)
            case .text(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
