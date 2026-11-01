// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_base64_document_source` (beta_managed_agents_base64_document_source.py).

import Foundation

/// Base64-encoded document data.
public struct BetaManagedAgentsBase64DocumentSource: Codable, Hashable, Sendable {
    /// Base64-encoded document data.
    public var data: String
    /// MIME type of the document (e.g., "application/pdf").
    public var mediaType: String
    public var type: String

    public init(data: String, mediaType: String, type: String = "base64") {
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
