// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_plain_text_document_source` (beta_managed_agents_plain_text_document_source.py).

import Foundation

/// Plain text document content.
public struct BetaManagedAgentsPlainTextDocumentSource: Codable, Hashable, Sendable {
    /// The plain text content.
    public var data: String
    /// MIME type of the text content. Must be "text/plain".
    public var mediaType: String
    public var type: String

    public init(data: String, mediaType: String = "text/plain", type: String = "text") {
        self.data = data
        self.mediaType = mediaType
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case data
        case mediaType = "media_type"
        case type
    }
}
