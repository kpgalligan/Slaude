// Transformed from `anthropic.types.beta.beta_managed_agents_system_content_block` (beta_managed_agents_system_content_block.py).

import Foundation

/// Content block in a mid-conversation system message. Text-only.
public struct BetaManagedAgentsSystemContentBlock: Codable, Hashable, Sendable {
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
