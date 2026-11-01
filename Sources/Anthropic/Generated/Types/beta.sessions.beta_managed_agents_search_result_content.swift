// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_search_result_content` (beta_managed_agents_search_result_content.py).

import Foundation

/// Text content within a search result.
public struct BetaManagedAgentsSearchResultContent: Codable, Hashable, Sendable {
    /// The text content.
    public var text: String
    public var type: String

    public init(text: String, type: String = "text") {
        self.text = text
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
    }
}
