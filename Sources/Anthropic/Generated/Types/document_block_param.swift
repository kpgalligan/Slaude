// Transformed from `anthropic.types.document_block_param` (document_block_param.py).

import Foundation

public struct DocumentBlockParam: Codable, Hashable, Sendable {
    public var source: DocumentBlockParam.Source
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var citations: CitationsConfigParam??
    public var context: String??
    public var title: String??

    public init(source: DocumentBlockParam.Source, type: String = "document", cacheControl: CacheControlEphemeralParam?? = nil, citations: CitationsConfigParam?? = nil, context: String?? = nil, title: String?? = nil) {
        self.source = source
        self.type = type
        self.cacheControl = cacheControl
        self.citations = citations
        self.context = context
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case source
        case type
        case cacheControl = "cache_control"
        case citations
        case context
        case title
    }
}

extension DocumentBlockParam {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(Base64PDFSourceParam)
        case text(PlainTextSourceParam)
        case content(ContentBlockSourceParam)
        case url(URLPDFSourceParam)
        case file(FileDocumentSourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try Base64PDFSourceParam(from: decoder))
            case "text": self = .text(try PlainTextSourceParam(from: decoder))
            case "content": self = .content(try ContentBlockSourceParam(from: decoder))
            case "url": self = .url(try URLPDFSourceParam(from: decoder))
            case "file": self = .file(try FileDocumentSourceParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .base64(let v): try v.encode(to: encoder)
            case .text(let v): try v.encode(to: encoder)
            case .content(let v): try v.encode(to: encoder)
            case .url(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
