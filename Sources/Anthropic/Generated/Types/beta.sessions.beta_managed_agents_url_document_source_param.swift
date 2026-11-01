// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_url_document_source_param` (beta_managed_agents_url_document_source_param.py).

import Foundation

/// Document referenced by URL.
public struct BetaManagedAgentsURLDocumentSourceParam: Codable, Hashable, Sendable {
    public var type: String
    /// URL of the document to fetch.
    public var url: String

    public init(type: String = "url", url: String) {
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
    }
}
