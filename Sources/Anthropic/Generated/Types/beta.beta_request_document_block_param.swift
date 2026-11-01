// Transformed from `anthropic.types.beta.beta_request_document_block_param` (beta_request_document_block_param.py).

import Foundation

public struct BetaRequestDocumentBlockParam: Codable, Hashable, Sendable {
    public var source: BetaRequestDocumentBlockParam.Source
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var citations: BetaCitationsConfigParamParam??
    public var context: String??
    public var title: String??

    public init(source: BetaRequestDocumentBlockParam.Source, type: String = "document", cacheControl: BetaCacheControlEphemeralParam?? = nil, citations: BetaCitationsConfigParamParam?? = nil, context: String?? = nil, title: String?? = nil) {
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

extension BetaRequestDocumentBlockParam {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaBase64PDFSourceParam)
        case text(BetaPlainTextSourceParam)
        case content(BetaContentBlockSourceParam)
        case url(BetaURLPDFSourceParam)
        case file(BetaFileDocumentSourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaBase64PDFSourceParam(from: decoder))
            case "text": self = .text(try BetaPlainTextSourceParam(from: decoder))
            case "content": self = .content(try BetaContentBlockSourceParam(from: decoder))
            case "url": self = .url(try BetaURLPDFSourceParam(from: decoder))
            case "file": self = .file(try BetaFileDocumentSourceParam(from: decoder))
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
