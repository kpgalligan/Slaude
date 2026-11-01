// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_document_block` (beta_managed_agents_document_block.py).

import Foundation

/// Document content, either specified directly as base64 data, as text, or as a reference via a URL.
public struct BetaManagedAgentsDocumentBlock: Codable, Hashable, Sendable {
    /// The source of the document data.
    public var source: BetaManagedAgentsDocumentBlock.Source
    public var type: String
    /// Additional context about the document for the model.
    public var context: String?
    /// The title of the document.
    public var title: String?

    public init(source: BetaManagedAgentsDocumentBlock.Source, type: String = "document", context: String? = nil, title: String? = nil) {
        self.source = source
        self.type = type
        self.context = context
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case source
        case type
        case context
        case title
    }
}

extension BetaManagedAgentsDocumentBlock {

    public indirect enum Source: Codable, Hashable, Sendable {
        case base64(BetaManagedAgentsBase64DocumentSource)
        case text(BetaManagedAgentsPlainTextDocumentSource)
        case url(BetaManagedAgentsURLDocumentSource)
        case file(BetaManagedAgentsFileDocumentSource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "base64": self = .base64(try BetaManagedAgentsBase64DocumentSource(from: decoder))
            case "text": self = .text(try BetaManagedAgentsPlainTextDocumentSource(from: decoder))
            case "url": self = .url(try BetaManagedAgentsURLDocumentSource(from: decoder))
            case "file": self = .file(try BetaManagedAgentsFileDocumentSource(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .base64(let v): try v.encode(to: encoder)
            case .text(let v): try v.encode(to: encoder)
            case .url(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
