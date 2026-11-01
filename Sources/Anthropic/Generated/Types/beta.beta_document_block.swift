// Transformed from `anthropic.types.beta.beta_document_block` (beta_document_block.py).

import Foundation

public struct BetaDocumentBlock: Codable, Hashable, Sendable {
    /// Citation configuration for the document
    public var citations: BetaCitationConfig?
    public var source: BetaDocumentBlock.Source
    /// The title of the document
    public var title: String?
    public var type: String

    public init(citations: BetaCitationConfig? = nil, source: BetaDocumentBlock.Source, title: String? = nil, type: String = "document") {
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

extension BetaDocumentBlock {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaBase64PDFSource)
        case text(BetaPlainTextSource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaBase64PDFSource(from: decoder))
            case "text": self = .text(try BetaPlainTextSource(from: decoder))
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
