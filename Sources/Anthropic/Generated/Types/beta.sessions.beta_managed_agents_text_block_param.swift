// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_text_block_param` (beta_managed_agents_text_block_param.py).

import Foundation

/// Regular text content.
public struct BetaManagedAgentsTextBlockParam: Codable, Hashable, Sendable {
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
